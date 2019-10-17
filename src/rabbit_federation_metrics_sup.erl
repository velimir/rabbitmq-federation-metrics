-module(rabbit_federation_metrics_sup).

-behaviour(supervisor2).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, _Arg = []).

init([]) ->
    {ok, {{one_for_one, 3, 10},
          [{rabbit_federation_metrics_worker,
            {rabbit_federation_metrics_worker, start_link, []},
            {permanent, 1000},
            5000,
            worker,
            [rabbit_federation_metrics_worker]}
          ]}}.
