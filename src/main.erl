%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. sty 2015 10:32
%%%-------------------------------------------------------------------
-module(main).
-author("krzysztof").
-import(utils, [sleep/1, readInput/0]).
-import(outerTemp, [tempOuter3/1, readOuterTemp/0, updateSeason/1]).
-import(heater, [heaterPower/2, maxHeaterPower/1, readHeaterPower/0, readMaxHeaterPower/0, switchHeater/1, updateHeaterPower/0]).
-import(clock, [clock/1,readHour/0, updateClockOneTick/0, updateTotalHour/1 ]).
-import(simulParams, [readTimeU/0,readTempExp/0, readCp_Mp/0, readIterSkipped/0,
        updateTu/1, updateTempExp/1, updateIterSkipped/1]).
-import(innerTemp, [updateInnerTemp/1, tempInner/1, readInnerTemp/0]).
%% API
-compile([export_all, debug_info]).


start()->
  register(connectionHandler, spawn(?MODULE, connectionHandler, [])),
  sleep(100000).

connectionHandler() ->
  receive
    {MBoxMainPid, MBoxSimulDataPid, start, {InitailInnerTemp, Season, Hour, HeaterLevel, TUnit, IterSkipped, TempExp}} ->
     % register(mBoxPid, MBoxPid),  Zamiast tego wrzucam do maina
      register(simulation, spawn(?MODULE, startSimulation, [InitailInnerTemp, Season, Hour, HeaterLevel, TUnit, IterSkipped, TempExp, MBoxSimulDataPid])),
      MBoxMainPid ! {ok},
      connectionHandler();

    {MBoxMainPid, changeTempExp, {NewTempExp}} ->
      updateTempExp(NewTempExp),
      MBoxMainPid ! {ok},
      connectionHandler();
    {MBoxMainPid, changeSeason, {Season}} ->
      updateSeason(Season),
      MBoxMainPid ! {ok},
      connectionHandler();
    {MBoxMainPid, changeIterSkipped, {IterSkipped}} ->
      updateIterSkipped(IterSkipped),
      MBoxMainPid ! {ok},
      connectionHandler();
    {MBoxMainPid, changeHeaterLevel, {Level}} ->
      switchHeater(Level),
      MBoxMainPid ! {ok},
      connectionHandler();
    {MBoxMainPid, changeHour, {NewHour}} ->
      updateTotalHour(NewHour),
      MBoxMainPid ! {ok},
      connectionHandler()
  end.


startSimulation()-> startSimulation(-1.2, 0, 0, 4,2* 3600, 1 , 20, 11111).
startSimulation(InitailInnerTemp, Season, Hour, HeaterLevel, TUnit,IterSkipped, TempExp, MBoxPid) ->
  register(innerTempPid,spawn(innerTemp, tempInner, [InitailInnerTemp])),
  register(outerTempPid,spawn(outerTemp, tempOuter, [Season])),
  register(simulParamsPid,spawn(simulParams, simulParams, [{TUnit, 120960.0, TempExp, IterSkipped}])), %{ TimeU = 60 sec, Cp_Mp = 120960, TempExp = 20 C }
  register(maxHeaterPower,spawn(heater, maxHeaterPower, [HeaterLevel * 500.0])),
  register(heaterPower,spawn(heater, heaterPower, [0, InitailInnerTemp])),
  register(clockPid,spawn(clock, clock, [Hour])),
  main(IterSkipped-1, MBoxPid).

main(I, MBoxSimulDataPid)->
  K_OI = 8.80,
  Cp_Mp = 120960,
  DeltaTemp = ( K_OI * differenceTemp() + readHeaterPower() ) * readTimeU() / Cp_Mp,
  updateClockOneTick(),
  updateInnerTemp(DeltaTemp),
  updateHeaterPower(),
  %updateOuterTemp(),

 if
   I>0 -> NewI = I-1;
   I == 0 ->
     % te dwie liniki ponizej zastepujemy wyslaniem messega z nowymi {innerTemp, OuterTemp, CurrentTime
     MBoxSimulDataPid ! {self(), readInnerTemp(), readHour(), readHeaterPower(), readOuterTemp()},
     io:format("Aktualny czas: ~p sekund ~n",[readHour()]),
     io:format("Aktualna temperatura: ~p stopni Celcjusza~n",[readInnerTemp()]),
     io:format("Aktualna moc farelki: ~p ~n",[readHeaterPower()]),
     io:format("Aktualny heater level: ~p ~n",[readMaxHeaterPower()]),
     io:format("Aktualny TempExp: ~p ~n",[readTempExp()]),
     io:format("Aktualny IterSkipped: ~p ~n",[readIterSkipped()]),
     io:format("Aktualna temp na zewnarz: ~p ~n",[readOuterTemp()]),
     sleep(1000),% tutaj można zrobić, zamiast tempego sleepa czekanie na podanie współczynników na receivie
    NewI = readIterSkipped()-1
 end,
main(NewI, MBoxSimulDataPid).

differenceTemp() ->
  readOuterTemp() - readInnerTemp().

hello()->
  io:format("Hello",[]).


