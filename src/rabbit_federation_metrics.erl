-module(rabbit_federation_metrics).

-behaviour(application).

-export([start/2, stop/1]).

start(normal, []) ->
    rabbit_federation_metrics_sup:start_link().

stop(_State) ->
    ok.
