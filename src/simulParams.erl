%%%-------------------------------------------------------------------
%%% @author Krzysiek P
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. sty 2015 17:08
%%%-------------------------------------------------------------------
-module(simulParams).
-author("Krzysiek P").
-import(utils, [readInput/0, sleep/1]).

%% API
-export([readCp_Mp/0, readTempExp/0, readTimeU/0, simulParams/1]).



simulParams(Params)->
  receive
    {updateTu, Tu} ->
      simulParams(setelement(1, Params, Tu));
    {updateCp_Mp, Cp_Mp} ->
      simulParams(setelement(2, Params, Cp_Mp));
    {updateTempExp, TempExp} ->
      simulParams(setelement(3, Params, TempExp));
    {read, Pid} -> Pid ! Params,
      simulParams(Params)
  end.


% to można zoptymalizować
readTimeU()->
  whereis(simulParamsPid)!{read, self()},
  element(1,readInput()).

readCp_Mp()->
  whereis(simulParamsPid)!{read, self()},
  element(2,readInput()).
readTempExp()->
  whereis(simulParamsPid)!{read, self()},
  element(3,readInput()).


