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
            %% Hello World
            {"/", index_handler, []},
            %% Package Info
            {"/[...]", package_handler, []}
        ]}
    ]),
    %% Define the paths to the certificate files
    CertFile = "/home/taylor/cowboy/cowboy_handler/ssl/fullchain.pem",
    KeyFile = "/home/taylor/cowboy/cowboy_handler/ssl/privkey.pem",
    %% Start the Cowboy HTTPS listener
    {ok, _} = cowboy:start_tls(https_listener, [
        {port, 443},
        {certfile, CertFile},
        {keyfile, KeyFile}
    ], #{env => #{dispatch => Dispatch}}),
    %% Start the application supervisor
    cowboy_handler_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
