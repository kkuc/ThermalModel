%%%-------------------------------------------------------------------
%%% @author Krzysiek P
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. sty 2015 18:44
%%%-------------------------------------------------------------------
-module(updating).
-author("Krzysiek P").
-import(utils, [sleep/1, readInput/0]).
-import(outerTemp, [tempOuter3/1, readOuterTemp/0, updateSeason/1]).
-import(heater, [heaterPower/2, maxHeaterPower/1, readHeaterPower/0, readMaxHeaterPower/0, switchHeater/1, updateHeaterPower/0]).
-import(clock, [clock/1,readHour/0, updateClockOneTick/0, updateTotalHour/1 ]).
-import(simulParams, [readTimeU/0,readTempExp/0, readCp_Mp/0, readIterSkipped/0,
updateTu/1, updateTempExp/1, updateIterSkipped/1]).
-import(innerTemp, [updateInnerTemp/1, tempInner/1, readInnerTemp/0]).
%% API
-export([checkForUpdatesAndDoThemAll/0]).

checkForUpdatesAndDoThemAll()->
  receive
    {MBoxMainPid, changeTempExp, {NewTempExp}} ->
      updateTempExp(NewTempExp),
      MBoxMainPid ! {ok},
      checkForUpdatesAndDoThemAll();
    {MBoxMainPid, changeSeason, {Season}} ->
      updateSeason(Season),
      MBoxMainPid ! {ok},
      checkForUpdatesAndDoThemAll();
    {MBoxMainPid, changeIterSkipped, {IterSkipped}} ->
      updateIterSkipped(IterSkipped),
      MBoxMainPid ! {ok},
      checkForUpdatesAndDoThemAll();
    {MBoxMainPid, changeHeaterLevel, {Level}} ->
      switchHeater(Level),
      MBoxMainPid ! {ok},
      checkForUpdatesAndDoThemAll();
    {MBoxMainPid, changeHour, {NewHour}} ->
      updateTotalHour(NewHour),
      MBoxMainPid ! {ok},
      checkForUpdatesAndDoThemAll()

  end.