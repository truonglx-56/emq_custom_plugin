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

-module(emq_custom_plugin_app).

-behaviour(application).
-include("emq_custom_plugin.hrl").
-import(emq_custom_plugin_mysql_cli, [parse_query/1]).

%% Application callbacks
-export([start/2, stop/1]).

start(_Type, _Args) ->
%%  Env = application:get_all_env(emq_custom_plugin),
  SuperQuery = parse_query(application:get_env(emq_custom_plugin, super_query, undefined)),
  Env = {SuperQuery},
  io:format("Load:~p~n", [Env]),

  {ok, Sup} = emq_custom_plugin_sup:start_link(Env),
  emq_custom_plugin:load(Env),
  {ok, Sup}.

stop(_State) ->
  emq_custom_plugin:unload().
