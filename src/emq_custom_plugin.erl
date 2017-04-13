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

-module(emq_custom_plugin).

-author("truonglx@bkav.com").

-behaviour(gen_server).

-include_lib("emqttd/include/emqttd.hrl").

-include_lib("emqttd/include/emqttd_internal.hrl").

-include_lib("stdlib/include/ms_transform.hrl").

%% gen_mod Callbacks
-export([load/1, unload/0]).

%% Hook Callbacks
-export([on_session_subscribed/4, on_message_publish/2]).

%% API Function Exports
-export([start_link/1]).

%% gen_server Function Exports
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
  terminate/2, code_change/3]).

-record(mqtt_retained, {topic, msg, ts}).
-record(query, {super_query}).

-record(state, {stats_fun, expiry_interval, stats_timer, expire_timer}).

%%--------------------------------------------------------------------
%% Load/Unload
%%--------------------------------------------------------------------

load(Env) ->
  emqttd:hook('session.subscribed', fun ?MODULE:on_session_subscribed/4, [Env]),
  emqttd:hook('message.publish', fun ?MODULE:on_message_publish/2, [Env]).

on_session_subscribed(_ClientId, _Username, {Topic, _Opts}, _Env) ->
  SessPid = self(),
  Msgs = case emqttd_topic:wildcard(Topic) of
           false -> read_messages(Topic);
           true -> match_messages(Topic)
         end,
  lists:foreach(fun(Msg) -> SessPid ! {dispatch, Topic, Msg} end, lists:reverse(Msgs)).

on_message_publish(Msg = #mqtt_message{payload = <<>>}, _Env) ->
  {stop, Msg};
on_message_publish(Msg = #mqtt_message{topic = <<"$SYS/", _/binary>>}, _Env) ->
  {stop, Msg};
on_message_publish(Msg = #mqtt_message{topic = Topic, retain = Retain, dup = Dup,
  headers = Headers, pktid = Pktid, from = From,
  qos = Qos, flags = Flags, payload = Payload,
  timestamp = Ts, sys = Sys, id = Id},
    Env) ->

  %%TruongLX: Todo

  _Id = lists:flatten(io_lib:format("~p", [Id])),
  _From = lists:flatten(io_lib:format("~p", [From])),
  _Topic = lists:flatten(io_lib:format("~p", [Topic])),
  _Headers = lists:flatten(io_lib:format("~p", [Headers])),
  _Payload = lists:flatten(io_lib:format("~p", [Payload])),
  _Ts = lists:flatten(io_lib:format("~p", [Ts])),
  io:fwrite("TruongLX-Custom-fuck: ~p~n", [Msg]),


  %%TruongLX: Todo
  emq_custom_plugin_mysql_cli:query
  ("INSERT INTO mqtt_message (id_packet, _from, topic, headers, payload, _timestamp) VALUES (?, ?, ?, ?, ?, ?)",
    [_Id, _From, _Topic, _Headers, _Payload, _Ts]),

  {ok, Msg#mqtt_message{retain = false}}.

unload() ->
  emqttd:unhook('session.subscribed', fun ?MODULE:on_session_subscribed/4),
  emqttd:unhook('message.publish', fun ?MODULE:on_message_publish/2).

%%--------------------------------------------------------------------
%% API
%%--------------------------------------------------------------------

%% @doc Start the custom plugin
-spec(start_link(Env :: list()) -> {ok, pid()} | ignore | {error, any()}).
start_link(Env) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [Env], []).

%%--------------------------------------------------------------------
%% gen_server Callbacks
%%--------------------------------------------------------------------

init({SuperQuery}) ->
  io:fwrite("TruongLX-Custom-fuck: ~p~n", [SuperQuery]),
  {ok, #query{super_query = SuperQuery}}.



handle_call(Req, _From, State) ->
  ?UNEXPECTED_REQ(Req, State).

handle_cast(Msg, State) ->
  ?UNEXPECTED_MSG(Msg, State).

handle_info(stats, State = #state{stats_fun = StatsFun}) ->
%%  StatsFun(retained_count()),
  {noreply, State, hibernate};

handle_info(expire, State = #state{expiry_interval = Never})
  when Never =:= 0 orelse Never =:= undefined ->
  {noreply, State, hibernate};

handle_info(expire, State = #state{expiry_interval = Interval}) ->
%%  expire_messages(emqttd_time:now_ms() - Interval),
  {noreply, State, hibernate};

handle_info(Info, State) ->
  ?UNEXPECTED_INFO(Info, State).

terminate(_Reason, _State = #state{stats_timer = TRef1, expire_timer = TRef2}) ->
  timer:cancel(TRef1), timer:cancel(TRef2).

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%--------------------------------------------------------------------
%% Internal Functions
%%--------------------------------------------------------------------

-spec(read_messages(binary()) -> [mqtt_message()]).
read_messages(Topic) ->
  [Msg || #mqtt_retained{msg = Msg} <- mnesia:dirty_read(mqtt_retained, Topic)].

-spec(match_messages(binary()) -> [mqtt_message()]).
match_messages(Filter) ->
  %% TODO: optimize later...
  Fun = fun(#mqtt_retained{topic = Name, msg = Msg}, Acc) ->
    case emqttd_topic:match(Name, Filter) of
      true -> [Msg | Acc];
      false -> Acc
    end
        end.
%%  mnesia:async_dirty(fun mnesia:foldl/3, [Fun, [], mqtt_retained]).

%%-spec(expire_messages(pos_integer()) -> any()).
%%expire_messages(Time) when is_integer(Time) ->
%%  mnesia:transaction(
%%    fun() ->
%%      Match = ets:fun2ms(
%%        fun(#mqtt_retained{topic = Topic, ts = Ts})
%%          when Time > Ts -> Topic
%%        end),
%%      Topics = mnesia:select(mqtt_retained, Match, write),
%%      lists:foreach(fun(<<"$SYS/", _/binary>>) -> ok; %% ignore $SYS/# messages
%%        (Topic) -> mnesia:delete({mqtt_retained, Topic})
%%                    end, Topics)
%%    end).

%%-spec(retained_count() -> non_neg_integer()).
%%retained_count() -> mnesia:table_info(mqtt_retained, size).

