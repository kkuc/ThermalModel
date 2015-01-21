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
-import(utils,[readInput/0]).
-import(simulParams, [readTimeU/0]).
%% API
-export([clock/1, updateClockOneTick/0, readHour/0]).

readHour() ->
  clockPid ! {read, self()},
  readInput().

updateClockOneTick() ->
  clockPid ! {update, readTimeU()}.

clock(Hour)->
  receive
    {update, TickLenth} ->
      NewHour = Hour + TickLenth,
      clock(NewHour);
    {read, Pid} -> Pid ! Hour,
      clock(Hour)
  end.
