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
-import(outerTemp, [tempOuter/1, readOuterTemp/0]).
-import(heater, [heaterPower/2, maxHeaterPower/1, readHeaterPower/0, readMaxHeaterPower/0, switchHeater/1]).
-import(clock, [clock/1,readHour/0, updateClockOneTick/0 ]).
-import(simulParams, [readTimeU/0,readTempExp/0, readCp_Mp/0, readIterSkipped/0]).
-import(innerTemp, [updateInnerTemp/1, tempInner/1, readInnerTemp/0]).
%% API
-compile([export_all, debug_info]).


connectionHandler() ->
  register(connectionHandler, self()),
  receive
    {MBoxPid, start, {InitailInnerTemp, Season, Hour, HeaterLevel, TUnit, IterSkipped, TempExp}} ->
      register(simulation, spawn(?MODULE, startSimulation, [InitailInnerTemp, Season, Hour, HeaterLevel, TUnit, IterSkipped, TempExp]));
    {MBoxPid, stop} ->
      true; % trzeba to zakodzic - jak ubic
    {MBoxPid, updateParams, {Season, Hour, HeaterLevel, TUnit, TempExp}} ->
      true

  end.


startSimulation()-> startSimulation(25, 0, 0, 1, 60, 2 , 20).
startSimulation(InitailInnerTemp, Season, Hour, HeaterLevel, TUnit,IterSkipped, TempExp) ->
  register(innerTempPid,spawn(innerTemp, tempInner, [InitailInnerTemp])),
  register(outerTempPid,spawn(outerTemp, tempOuter, [-10])),
  register(simulParamsPid,spawn(simulParams, simulParams, [{TUnit, 120960, TempExp, IterSkipped}])), %{ TimeU = 60 sec, Cp_Mp = 120960, TempExp = 20 C }
  register(maxHeaterPower,spawn(heater, maxHeaterPower, [HeaterLevel * 500])),
  register(heaterPower,spawn(heater, heaterPower, [HeaterLevel*500, InitailInnerTemp])),
  register(clockPid,spawn(clock, clock, [Hour])),
main(IterSkipped-1).

main(I)->

  K_OI = 8.80,
  Cp_Mp = 120960,
  DeltaTemp = ( K_OI * differenceTemp() + readHeaterPower() ) * readTimeU() / Cp_Mp,
  updateInnerTemp(DeltaTemp),
 updateClockOneTick(),
 if
   I>0 -> NewI = I-1;
   I == 0 ->
     % te dwie liniki ponizej zastepujemy wyslaniem messega z nowymi {innerTemp, OuterTemp, CurrentTime
     io:format("Aktualny czas: ~p sekund ~n",[readHour()]),
     io:format("Aktualna temperatura: ~p stopni Celcjusza~n",[readInnerTemp()]),
     sleep(1000),% tutaj można zrobić, zamiast tempego sleepa czekanie na podanie współczynników na receivie
    NewI = readIterSkipped()-1
 end,
main(NewI).

differenceTemp() ->
  readOuterTemp() - readInnerTemp().



