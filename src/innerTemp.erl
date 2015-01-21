%%%-------------------------------------------------------------------
%%% @author Krzysiek P
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. sty 2015 17:11
%%%-------------------------------------------------------------------
-module(innerTemp).
-author("Krzysiek P").
-import(utils, [readInput/0, sleep/1]).
%% API
-export([readInnerTemp/0, tempInner/1, updateInnerTemp/1]).


readInnerTemp() ->
  whereis(innerTempPid)!{read, self()},
  readInput().

updateInnerTemp(DeltaTemp) ->
  whereis(innerTempPid)!{update, DeltaTemp}.

tempInner(Temp)->
  receive
    {update, Delta} ->
      tempInner(Temp+Delta);
    {read, Pid} -> Pid ! Temp,
      tempInner(Temp)
  end.

