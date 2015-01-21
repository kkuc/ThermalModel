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
-import(utils, [readInput/0, sleep/1]).
%% API
-export([readOuterTemp/0, tempOuter/1]).


readOuterTemp() ->
  whereis(outerTempPid)!{read, self()},
  readInput().

tempOuter(Temp)->
  receive
    {read, Pid} -> Pid ! Temp,
      tempOuter(Temp)
  end.

