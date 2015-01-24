%%%-------------------------------------------------------------------
%%% @author Krzysiek P
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. sty 2015 23:35
%%%-------------------------------------------------------------------
-module(clock).
-author("Krzysiek P").
-import(utils,[readInput/0, readSelectInput/1]).
-import(simulParams, [readTimeU/0]).
%% API
-export([clock/1, updateClockOneTick/0, readHour/0, updateTotalHour/1]).

readHour() ->
  clockPid ! {read, self()},
  readSelectInput(clock).

updateClockOneTick() ->
  clockPid ! {update, readTimeU(), self()},
  receive
    {ok} ->
      true
  end.

updateTotalHour(NewHour)->
  clockPid ! {totalUpdate, NewHour, self()},
  receive
    {ok} ->
      true
  end.

clock(Hour)->
  receive
    {update, TickLenth, Pid} ->
      NewHour = Hour + TickLenth,
      if
        NewHour > 3600 * 24 ->
          NewHour2 = NewHour - 3600 * 24;
        NewHour =< 3600 * 24 ->
          NewHour2 = NewHour
      end,
      Pid ! {ok},
      clock(NewHour2);
    {totalUpdate, NewHour, Pid}->
      Pid ! {ok},
      clock(NewHour);
    {read, Pid} ->
      Pid ! {clock, Hour},
      clock(Hour)
  end.
