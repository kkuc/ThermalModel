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

-import(simulParams, [readTimeU/0,readTempExp/0, readCp_Mp/0 ]).
-import(innerTemp, [updateInnerTemp/1, tempInner/1, readInnerTemp/0]).
%% API
-compile([export_all, debug_info]).


startSimulation()-> startSimulation(20, -10).
startSimulation(TInner, TOuter) ->
  register(innerTempPid,spawn(innerTemp, tempInner, [TInner])),
  register(outerTempPid,spawn(outerTemp, tempOuter, [TOuter])),
  register(simulParamsPid,spawn(simulParams, simulParams, [{10, 120960, 20}])), %{ TimeU = 60 sec, Cp_Mp = 120960, TempExp = 20 C }
  register(maxHeaterPower,spawn(heater, maxHeaterPower, [500])),
  register(heaterPower,spawn(heater, heaterPower, [500, TInner])),
main(0, 60).

main(ActualTime, DeltaTime)->
  sleep(1000),% tutaj można zrobić, zamiast tempego sleepa czekanie na podanie współczynników na receivie
  K_OI = 8.80,
  Cp_Mp = 120960,
  DeltaTemp = ( K_OI * differenceTemp() + readHeaterPower() ) * DeltaTime / Cp_Mp,
  updateInnerTemp(DeltaTemp),
  NewTime = ActualTime + DeltaTime,
  io:format("Aktualny czas: ~p sekund ~n",[NewTime]),
  io:format("Aktualna temperatura: ~p stopni Celcjusza~n",[readInnerTemp()]),
  main(NewTime, DeltaTime).

differenceTemp() ->
  readOuterTemp() - readInnerTemp().
