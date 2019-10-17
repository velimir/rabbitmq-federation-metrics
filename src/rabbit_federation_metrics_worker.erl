-module(rabbit_federation_metrics_worker).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {}).

-include_lib("rabbit_common/include/rabbit.hrl").

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%---------------------------
%% Gen Server Implementation
%%---------------------------

init([]) ->
    schedule_print(0),
    {ok, #state{}}.

handle_call(_Msg, _From, State) ->
    {reply, unknown_command, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_info(print_metrics, State) ->
    print_metrics(),
    schedule_print(),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%------------------
%% Private functions
%%------------------
print_metrics() ->
    Links  = local_links(),
    {ok, Items} = application:get_env(rabbitmq_federation_metrics, items),
    [prit_metrics(Pid, VHost, Items) || {Pid, VHost} <- Links].

prit_metrics(Pid, VHost, Items) ->
    case process_info(Pid, Items) of
        undefined ->
            ok;
        Info when is_list(Info) ->
            print_metrics(VHost, Info)
    end.

print_metrics(VHost, Info) ->
    rabbit_log:info("Federation metrics (~s): ~w", [VHost, Info]).

local_links() ->
    lists:flatten(
      [begin
           case pg2:get_local_members(G) of
               {error, {no_such_group, _}} ->
                   [];
               Pids ->
                   VHost = Resource#resource.virtual_host,
                   [{Pid, VHost} || Pid <- Pids]
           end
       end || {rabbit_federation_exchange, Resource} = G <- pg2:which_groups()]).

schedule_print() ->
    {ok, Interval} = application:get_env(rabbitmq_federation_metrics, interval),
    schedule_print(Interval).

schedule_print(Interval) ->
    erlang:send_after(Interval, self(), print_metrics).
