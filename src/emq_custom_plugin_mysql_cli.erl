%%--------------------------------------------------------------------
%% Copyright (c) 2013-2017 EMQ Enterprise, Inc. (http://emqtt.io)
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

%% @doc MySQL Authentication/ACL Client
-module(emq_custom_plugin_mysql_cli).

-behaviour(ecpool_worker).

-include("emq_custom_plugin.hrl").

-include_lib("emqttd/include/emqttd.hrl").

-export([connect/1, query/2, replvar/2, replvar/3, parse_query/1]).

%%--------------------------------------------------------------------
%% MySQL Connect/Query
%%--------------------------------------------------------------------

connect(Options) ->
  io:fwrite("TruongLX-Connect-Custom: ~p~n", [Options]),
%% Connect
  mysql:start_link(Options).

query(Sql, Params) ->
  io:fwrite("TruongLX-Connect-Custom: ~p~n", [Sql]),
  ecpool:with_client(?APP, fun(C) -> mysql:query(C, Sql, Params) end).


replvar(Params, Message) ->
  replvar(Params, Message, []).

replvar([], _Message, Acc) ->
  lists:reverse(Acc);
replvar(["'%u'" | Params], _Message = #mqtt_message{id = Id}, Acc) ->
  replvar(Params, _Message, [Id | Acc]);
replvar(["'%c'" | Params], _Message = #mqtt_message{topic = Topic}, Acc) ->
  replvar(Params, _Message, [Topic | Acc]);
replvar(["'%a'" | Params], _Message = #mqtt_message{payload = Payload}, Acc) ->
  replvar(Params, _Message, [Payload | Acc]);

replvar([Param | Params], _Message, Acc) ->
  replvar(Params, _Message, [Param | Acc]).
parse_query(undefined) ->
  undefined;
parse_query(Sql) ->
  case re:run(Sql, "'%[uca]'", [global, {capture, all, list}]) of
    {match, Variables} ->
      Params = [Var || [Var] <- Variables],
      {re:replace(Sql, "'%[uca]'", "?", [global, {return, list}]), Params};
    nomatch ->
      {Sql, []}
  end.
