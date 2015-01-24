%%%-------------------------------------------------------------------
%%% @author Krzysiek P
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. sty 2015 17:07
%%%-------------------------------------------------------------------
-module(outerTemp).
-author("Krzysiek P").
-import(utils, [readInput/0, sleep/1,readSelectInput/1]).
 -import(clock, [readHour/0]).
%% API
-export([readOuterTemp/0, tempOuter3/1, tempOuter/1, updateSeason/1, readSeason/0]).


readOuterTemp() ->
  whereis(outerTempPid)!{read, self()},
  readSelectInput(outerTemp).

readSeason() ->
  whereis(outerTempPid)!{readSeason, self()},
  readSelectInput(outerTemp).

tempOuter3(Temp)->
  receive
    {read, Pid} ->
      Pid ! {outerTemp, Temp},
      tempOuter3(Temp)
  end.

tempOuter(Season)->
  receive
    {read, Pid} ->
      Temp = seasonTempAtHour(Season, readHour()/3600),
      Pid ! {outerTemp, Temp},
      tempOuter(Season);
    {readSeason, Pid} ->
      Pid ! {outerTemp, Season},
      tempOuter(Season);
    {update,NewSeason, Pid} ->
      Pid ! {ok},
      tempOuter(NewSeason)

  end.

updateSeason(Season) ->
  outerTempPid ! {update, Season, self()},
  receive
    {ok} ->
      true
  end.


seasonTempAtHour(Season, Hour) ->
  if
    Hour < 1 ->
      Temp = element(Season, {2, 16, 0, -7});
    Hour < 2 ->
      Temp = element(Season, {1, 13, 0, -8});
    Hour < 3 ->
      Temp = element(Season, {1, 12, -1, -8});
    Hour < 4 ->
      Temp = element(Season, {0, 14, -1, -9});
    Hour < 5 ->
      Temp = element(Season, {-1, 17, -2, -9});
    Hour < 6 ->
      Temp = element(Season, {0, 20, -2, -10});
    Hour < 7 ->
      Temp = element(Season, {4, 23, -2, -10});
    Hour < 8 ->
      Temp = element(Season, {7, 26, 1, -8});
    Hour < 9 ->
      Temp = element(Season, {10, 28, 4, -6});
    Hour < 10 ->
      Temp = element(Season, {13, 29, 6, -4});
    Hour < 11 ->
      Temp = element(Season, {14, 30, 7, -2});
    Hour < 12 ->
      Temp = element(Season, {14, 30, 9, -1});
    Hour < 13 ->
      Temp = element(Season, {15, 31, 10, -1});
    Hour < 14 ->
      Temp = element(Season, {15, 31, 10, -1});
    Hour < 15 ->
      Temp = element(Season, {16, 31, 10, -2});
    Hour < 16 ->
      Temp = element(Season, {16, 30, 9, -2});
    Hour < 17 ->
      Temp = element(Season, {15, 30, 7, -3});
    Hour < 18 ->
      Temp = element(Season, {12, 29, 7, -3});
    Hour < 19 ->
      Temp = element(Season, {10, 26, 4, -4});
    Hour < 20 ->
      Temp = element(Season, {8, 23, 3, -5});
    Hour < 21 ->
      Temp = element(Season, {6, 22, 2, -6});
    Hour < 22 ->
      Temp = element(Season, {4, 21, 2, -6});
    Hour < 23 ->
      Temp = element(Season, {3, 20, 1, -7});
    Hour =< 24 ->
      Temp = element(Season, {2, 18, 1, -7})
  end,
    Temp.


