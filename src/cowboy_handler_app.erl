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
    PrivDir = code:priv_dir(cowboy_handler),
        {ok,_} = cowboy:start_tls(https_listener, [
            {port, 443},
            {certfile, PrivDir ++ "/ssl/fullchain.pem"},
            {keyfile, PrivDir ++ "/ssl/privkey.pem"}
                ], #{env => #{dispatch => Dispatch}}),
    cowboy_handler_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
