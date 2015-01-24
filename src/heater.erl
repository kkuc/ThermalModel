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
-import(utils, [readInput/0, sleep/1, readSelectInput/1]).
-import(simulParams, [readTimeU/0,readTempExp/0, readCp_Mp/0 ]).
-import(innerTemp, [updateInnerTemp/1, tempInner/1, readInnerTemp/0]).
%% API
-export([heaterPower/2, readHeaterPower/0, maxHeaterPower/1, readMaxHeaterPower/0, switchHeater/1, updateHeaterPower/0, readHeaterLevel/0]).

heaterPower(PreviousPower, LastInnerTemp)->
  receive
    {read, Pid} ->
      Pid ! {heaterPower, PreviousPower},
      heaterPower(PreviousPower, LastInnerTemp);
    {update, Pid} ->
      % to niżej to      =  Energia od grzejnika dana pokojowi - energia, o którą sumarycznie pokój się wzbogacił
      EnergyGiven = PreviousPower * readTimeU(),
      TemperatureDifference = readInnerTemp()-LastInnerTemp,
      TemperatureEnergyChange = TemperatureDifference * readCp_Mp(),
      EnergyMovedOutside = EnergyGiven - (TemperatureEnergyChange), % to co upływa jest dodatnio
      % zatem uzyskujemy w wyniku energię, która uszła na zewnątrz
      EnergyToExpectTemp = (readTempExp() - readInnerTemp()) * readCp_Mp(),
      EnergyNeeded = EnergyToExpectTemp + EnergyMovedOutside,
      PowerNedded = EnergyNeeded/readTimeU(),
      if
        EnergyToExpectTemp > 0 -> NewPower = max(min(PowerNedded, readMaxHeaterPower()),0.0);
        EnergyToExpectTemp == 0 -> NewPower = PreviousPower;
        EnergyToExpectTemp < 0 -> NewPower = min(max(PowerNedded, 0.0), readMaxHeaterPower())
      %tak jak pierwszy case tylko tutaj Energy Needed jest ujemne, nie do końca dobre, ale i tak nie powinno dojść do tego przypadku
      end,
      Pid ! {ok},
      heaterPower(NewPower, readInnerTemp())
  end.

readHeaterPower() ->
  whereis(heaterPower)!{read, self()},
  readSelectInput(heaterPower).


updateHeaterPower() ->
  whereis(heaterPower) ! {update, self()},
 receive
   {ok} ->
     true
 end.


readMaxHeaterPower() ->
  whereis(maxHeaterPower)!{read, self()},
  readSelectInput(maxHeaterPower).

readHeaterLevel() ->
  readMaxHeaterPower()/500.

switchHeater(Level)->
  whereis(maxHeaterPower)!{switch, Level, self()},
  receive
    {ok} ->
      true
  end.


maxHeaterPower(MaxPower)->
  receive
    {switch,A, Pid} ->
      Pid ! {ok},
      maxHeaterPower((A)*500.0);
    {read, Pid} ->
      Pid ! {maxHeaterPower, MaxPower},
      maxHeaterPower(MaxPower)
  end.

