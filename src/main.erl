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
-import(outerTemp, [tempOuter3/1, readOuterTemp/0, updateSeason/1, readSeason/0]).
-import(heater, [heaterPower/2,readHeaterLevel/0, maxHeaterPower/1, readHeaterPower/0, readMaxHeaterPower/0, switchHeater/1, updateHeaterPower/0]).
-import(clock, [clock/1,readHour/0, updateClockOneTick/0, updateTotalHour/1 ]).
-import(simulParams, [readTimeU/0,readTempExp/0, readCp_Mp/0, readIterSkipped/0,
        updateTu/1, updateTempExp/1, updateIterSkipped/1]).
-import(innerTemp, [updateInnerTemp/1, tempInner/1, readInnerTemp/0]).
-import(updating, [checkForUpdatesAndDoThemAll/0]).
%% API
-compile([export_all, debug_info]).


start()->
  register(connectionHandler, self()),
  connectionHandler(trash).


connectionHandler(MBoxSimulData) ->
  receive
    {MBoxMainPid, NewMBoxSimulData, start, {InitialInnerTemp, Season, Hour, HeaterLevel, TUnit, IterSkipped, TempExp, CurrentHeaterPower, K_OI, Cp_Mp}} ->
     % register(mBoxPid, MBoxPid),  Zamiast tego wrzucam do maina
      register(simulation, spawn(?MODULE, startSimulation, [InitialInnerTemp, Season, Hour, HeaterLevel, TUnit, IterSkipped, TempExp, CurrentHeaterPower, NewMBoxSimulData, K_OI, Cp_Mp])),
      monitor(process, whereis(simulation)),
      MBoxMainPid ! {ok},
      connectionHandler(NewMBoxSimulData);
    {Message, Ref, process, PidOfCrashedProcess, stopSimul}->
      io:format("Zdechl proces: ~p simulation z powodu: ~p ~n",[PidOfCrashedProcess,"stopSimul"]),
      io:format("Pid symulacji: ~p  ~n",[whereis(simulation)]),
      io:format("Message: ~p ~n",[Message]),
      connectionHandler(MBoxSimulData);
    {Message, Ref, process, PidOfCrashedProcess, Reason}->
      io:format("Zdechl proces: ~p simulation z powodu: ~p ~n",[PidOfCrashedProcess,Reason]),
      io:format("Pid symulacji: ~p  ~n",[whereis(simulation)]),
      io:format("Message: ~p ~n",[Message]),
      MBoxSimulData ! {crash},
      %tu trzeba dodac powiadomienie dla Javy
      connectionHandler(MBoxSimulData);
    {MBoxMainPid, stopSimulation} ->
      exit(whereis(simulation), stopSimul),
      MBoxMainPid ! {ok},
      connectionHandler(MBoxSimulData);
    {MBoxMainPid, closeAll} ->
      %exit(whereis(simulation), kill),  % trzeba bylo wywalić, bo whereis(simulation) moze zwracan undefined i wywala blad
      MBoxMainPid ! {ok}
  after 10000000 ->
    true
  end.


%startSimulation()-> startSimulation(-1.2, 0, 0, 4,2* 3600, 1 , 20, 11111).
startSimulation(InitailInnerTemp, Season, Hour, HeaterLevel, TUnit,IterSkipped, TempExp, CurrentHeaterPower, MBoxPid, K_OI, Cp_Mp) ->
  register(innerTempPid,spawn_link(innerTemp, tempInner, [InitailInnerTemp])),
  register(outerTempPid,spawn_link(outerTemp, tempOuter, [Season])),
  register(simulParamsPid,spawn_link(simulParams, simulParams, [{TUnit, 120960.0, TempExp, IterSkipped}])), %{ TimeU = 60 sec, Cp_Mp = 120960, TempExp = 20 C }
  register(maxHeaterPower,spawn_link(heater, maxHeaterPower, [HeaterLevel * 500.0])),
  register(heaterPower,spawn_link(heater, heaterPower, [CurrentHeaterPower, InitailInnerTemp])),
  register(clockPid,spawn_link(clock, clock, [Hour])),
  register(updatingPid,spawn_link(updating, checkForUpdatesAndDoThemAll, [])),
  main(IterSkipped-1, MBoxPid, K_OI, Cp_Mp).

main(I, MBoxSimulDataPid, K_OI, Cp_Mp)->
 % K_OI = 8.80,
  %Cp_Mp = 120960,
  DeltaTemp = ( K_OI * differenceTemp() + readHeaterPower() ) * readTimeU() / Cp_Mp,
  updateClockOneTick(),
  updateInnerTemp(DeltaTemp),
  updateHeaterPower(),
  %updateOuterTemp(),

 if
   I>0 -> NewI = I-1;
   I == 0 ->
     % te dwie liniki ponizej zastepujemy wyslaniem messega z nowymi {innerTemp, OuterTemp, CurrentTime
     MBoxSimulDataPid ! {simulData, readInnerTemp(), readSeason(), readHour(), readHeaterLevel(), readTimeU(),
       readIterSkipped(), readTempExp(), readHeaterPower(), readOuterTemp(), K_OI, Cp_Mp},
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
main(NewI, MBoxSimulDataPid, K_OI, Cp_Mp).

differenceTemp() ->
  readOuterTemp() - readInnerTemp().

hello()->
  io:format("Hello",[]).


