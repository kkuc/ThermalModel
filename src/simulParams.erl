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
-import(utils, [readInput/0, sleep/1, readSelectInput/1]).

%% API
-export([readCp_Mp/0, readTempExp/0, readTimeU/0, simulParams/1, readIterSkipped/0]).

% Params == {TUnit, Cp_Mp, TempExp}

simulParams(Params)->
  receive
    {updateTu, TUnit} ->
      simulParams(setelement(1, Params, TUnit));
    {updateCp_Mp, Cp_Mp} ->
      simulParams(setelement(2, Params, Cp_Mp));
    {updateTempExp, TempExp} ->
      simulParams(setelement(3, Params, TempExp));
    {updateIterSkipped, IterSkipped} ->
      simulParams(setelement(4, Params, IterSkipped));
    {read, Pid} ->
      Pid ! {simulParams, Params},
      simulParams(Params)
  end.


% to można zoptymalizować
readTimeU()->
  whereis(simulParamsPid)!{read, self()},
  element(1,readSelectInput(simulParams)).

readCp_Mp()->
  whereis(simulParamsPid)!{read, self()},
  element(2,readSelectInput(simulParams)).
readTempExp()->
  whereis(simulParamsPid)!{read, self()},
  element(3,readSelectInput(simulParams)).
readIterSkipped()->
  whereis(simulParamsPid)!{read, self()},
  element(4,readSelectInput(simulParams)).


