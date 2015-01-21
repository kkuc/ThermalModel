%%%-------------------------------------------------------------------
%%% @author Krzysiek P
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. sty 2015 17:06
%%%-------------------------------------------------------------------
-module(heater).
-author("Krzysiek P").
-import(utils, [readInput/0, sleep/1]).
-import(simulParams, [readTimeU/0,readTempExp/0, readCp_Mp/0 ]).
-import(innerTemp, [updateInnerTemp/1, tempInner/1, readInnerTemp/0]).
%% API
-export([heaterPower/2, readHeaterPower/0,maxHeaterPower/1,readMaxHeaterPower/0, switchHeater/1]).

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

readHeaterPower() ->
  whereis(heaterPower)!{read, self()},
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

