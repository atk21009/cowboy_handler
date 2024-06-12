%%%-------------------------------------------------------------------
%% @doc cowboy_handler public API
%% @end
%%%-------------------------------------------------------------------

-module(cowboy_handler_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", default_page_h, []}
        ]}
    ]),
    cowboy:start_clear(
        my_http_listener,
        [{port, 80}],
        #{env => #{dispatch => Dispatch}}
    ),
    cowboy_handler_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
