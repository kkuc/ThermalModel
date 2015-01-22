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
-import(utils, [readInput/0, sleep/1, readSelectInput/1]).
%% API
-export([readInnerTemp/0, tempInner/1, updateInnerTemp/1]).


readInnerTemp() ->
  innerTempPid !{read, self()},
  readSelectInput(innerTemp).

updateInnerTemp(DeltaTemp) ->
  whereis(innerTempPid)!{update, DeltaTemp, self()},
  receive
    {ok} ->
      true
  end.

tempInner(Temp)->
  receive
    {update, Delta, Pid} ->
      Pid ! {ok},
      tempInner(Temp+Delta);

    {read, Pid} ->
      Pid ! {innerTemp, Temp},
      tempInner(Temp)
  end.

