%%%-------------------------------------------------------------------
%%% @author Krzysiek P
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. sty 2015 17:05
%%%-------------------------------------------------------------------
-module(utils).
-author("Krzysiek P").

%% API
-export([sleep/1, readInput/0]).

sleep(T)->
  receive
  after T ->
    true
  end.

readInput()->
  receive
    All -> All
  end.