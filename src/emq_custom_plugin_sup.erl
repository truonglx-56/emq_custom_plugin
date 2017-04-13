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

-module(emq_custom_plugin_sup).

-include("emq_custom_plugin.hrl").

-behaviour(supervisor).

-export([start_link/1]).

-export([init/1]).

start_link(Env) ->
  io:fwrite("TruongLX-Start-link: ~p~n", [Env]),
  supervisor:start_link({local, ?MODULE}, ?MODULE, [Env]).

init([]) ->
  %% MySQL Connection Pool.
  {ok, Server} = application:get_env(emq_custom_plugin, server),
  io:fwrite("TruongLX-Server-Custom: ~p~n", [Server]),
  PoolSpec = ecpool:pool_spec(?APP, ?APP, emq_custom_plugin_mysql_cli, Server),
  io:fwrite("TruongLX-PoolSpec-Custom: ~p~n", [PoolSpec]),

  {ok, {{one_for_one, 10, 100}, [PoolSpec]}}.
%%  {ok, {{one_for_one, 10, 100}, [
%%    {?M, {?M, start_link, [Env]}, permanent, 5000, worker, [?M]}]}}.

