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
-export([clock/1, updateClockOneTick/0, readHour/0]).

readHour() ->
  clockPid ! {read, self()},
  readSelectInput(clock).

updateClockOneTick() ->
  clockPid ! {update, readTimeU(), self()},
  receive
    {ok} ->
      true
  end.

clock(Hour)->
  receive
    {update, TickLenth, Pid} ->
      NewHour = Hour + TickLenth,
      Pid ! {ok},
      clock(NewHour);
    {read, Pid} ->
      Pid ! {clock, Hour},
      clock(Hour)
  end.
