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
-compile([export_all, debug_info]).


sleep(T)->
  receive
    after T ->
      true
  end.

startSimulation()-> startSimulation(20, -10).
startSimulation(TInner, TOuter) ->
  register(innerTempPid,spawn(?MODULE, tempInner, [TInner])),
  register(outerTempPid,spawn(?MODULE, tempOuter, [TOuter])),
  register(simulParamsPid,spawn(?MODULE, simulParams, [{10, 120960, 20}])), %{ TimeU = 60 sec, Cp_Mp = 120960, TempExp = 20 C }
  register(maxHeaterPower,spawn(?MODULE, maxHeaterPower, [500])),
  register(heaterPower,spawn(?MODULE, heaterPower, [500, TInner])),
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

readInnerTemp() ->
  whereis(innerTempPid)!{read, self()},
  readInput().

updateInnerTemp(DeltaTemp) ->
  whereis(innerTempPid)!{update, DeltaTemp}.

readOuterTemp() ->
  whereis(outerTempPid)!{read, self()},
  readInput().

readHeaterPower() ->
  whereis(heaterPower)!{read, self()},
  readInput().

heaterPower(PreviousPower, LastInnerTemp)->
  receive
    {read, Pid} ->
      % to niżej to      =  Energia od grzejnika dana pokojowi - energia, o którą sumarycznie pokój się wzbogacił
      EnergyMovedOutside = PreviousPower * readTimeU() - ((readInnerTemp()-LastInnerTemp) * readCp_Mp()), % to co upływa jest dodatnio
      % zatem uzyskujemy w wyniku energię, która uszła na zewnątrz
      EnergyNeeded = (readTempExp() - readInnerTemp()) * readCp_Mp(),
      if
        EnergyNeeded > 0 -> NewPower = max(min(EnergyNeeded + EnergyMovedOutside, readMaxHeaterPower()),0);
        EnergyNeeded == 0 -> NewPower = PreviousPower;
        EnergyNeeded < 0 -> NewPower = min(max(EnergyNeeded + EnergyMovedOutside, 0), readMaxHeaterPower())
        %tak jak pierwszy case tylko tutaj Energy Needed jest ujemne, nie do końca dobre, ale i tak nie powinno dojść do tego przypadku
      end,
      Pid ! NewPower,
      heaterPower(NewPower, readInnerTemp())
  end.

readMaxHeaterPower() ->
  whereis(maxHeaterPower)!{read, self()},
  readInput().

switchHeater(Level)->
  whereis(maxHeaterPower)!{switch, Level}.


maxHeaterPower(MaxPower)->
  receive
    {switch,0} ->
      maxHeaterPower(0);
    {switch,1} ->
      maxHeaterPower(500);
    {switch,2} ->
      maxHeaterPower(1000);
    {switch,3} ->
      maxHeaterPower(1500);
    {switch,4} ->
      maxHeaterPower(2000);
    {read, Pid} -> Pid ! MaxPower,
      maxHeaterPower(MaxPower)
  end.




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

simulParams(Params)->
  receive
    {updateTu, Tu} ->
      simulParams(setelement(1, Params, Tu));
    {updateCp_Mp, Cp_Mp} ->
      simulParams(setelement(2, Params, Cp_Mp));
    {updateTempExp, TempExp} ->
      simulParams(setelement(3, Params, TempExp));
    {read, Pid} -> Pid ! Params,
      simulParams(Params)
  end.


% to można zoptymalizować
readTimeU()->
  whereis(simulParamsPid)!{read, self()},
  element(1,readInput()).

readCp_Mp()->
  whereis(simulParamsPid)!{read, self()},
  element(2,readInput()).
readTempExp()->
  whereis(simulParamsPid)!{read, self()},
  element(3,readInput()).


