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

%% API
-compile([export_all]).

hello()->
  io:format("Hello, world!~n").

sleep(T)->
  receive
    after T ->
      true
  end.

startSimulation()-> startSimulation(20, -10).
startSimulation(TInner, TOuter) ->
  register(innerTempPid,spawn(?MODULE, tempInner, [TInner])),
  register(outerTempPid,spawn(?MODULE, tempOuter, [TOuter])),
  main(0, 10).

main(ActualTime, DeltaTime)->
  sleep(1000),% tutaj można zrobić, zamiast tempego sleepa czekanie na podanie współczynników na receivie
  K_OI = 8.80,
  Cp_Mp = 120960,
  DeltaTemp = K_OI * differenceTemp() * DeltaTime / Cp_Mp,
  updateInnerTemp(DeltaTemp),
  NewTime = ActualTime + DeltaTime,
  io:format("Aktualny czas: ~p sekund ~n",[NewTime]),
  io:format("Aktualna temperatura: ~p stopni Celcjusza~n",[readInnerTemp()]),
  main(NewTime, DeltaTime).

differenceTemp() ->
  readOuterTemp() - readInnerTemp().

readInnerTemp() ->
  whereis(innerTempPid)!{read, self()},
  readInput().

updateInnerTemp(DeltaTemp) ->
  whereis(innerTempPid)!{update, DeltaTemp}.

readOuterTemp() ->
  whereis(outerTempPid)!{read, self()},
  readInput().




tempInner(Temp)->
  receive
    {update, Delta} ->
      tempInner(Temp+Delta);
    {read, Pid} -> Pid ! Temp,
      tempInner(Temp)
  end.

tempOuter(Temp)->
  receive
    {read, Pid} -> Pid ! Temp,
      tempOuter(Temp)
  end.

readInput()->
  receive
    All -> All
  end.