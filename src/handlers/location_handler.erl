-module(location_handler).
-export([init/2]).

init(Req0, _Opts) ->
    Method = cowboy_req:method(Req0),
    Path = cowboy_req:path(Req0),
    {ok, Data, _} = cowboy_req:read_body(Req0),
    DecodedData = case Data of
        <<>> -> {};  % Empty body
        _ -> jsx:decode(Data)
    end,

    % Ping logic@logic.taylor58.dev to establish connection
    case net_adm:ping('logic@logic.taylor58.dev') of
        pong ->
            % If ping successful, make RPC call
            case erpc:call('logic@logic.taylor58.dev', location_server, location, [Method, Path, DecodedData]) of
                {ok, Response} ->
                    ResponseData = jsx:encode(Response),
                    Req = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, ResponseData, Req0),
                    {ok, Req, _Opts};
                {fail, Reason} ->
                    ErrorResponse = jsx:encode(#{error => Reason}),
                    Req = cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, ErrorResponse, Req0),
                    {fail, Req, _Opts};
                {'EXIT', Reason} ->
                    ErrorResponse = jsx:encode(#{error => erpc_failed, reason => Reason}),
                    Req = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>}, ErrorResponse, Req0),
                    {fail, Req, _Opts}
            end;
        pang ->
            % If ping fails, handle the situation (e.g., log error, reply with error response)
            ErrorResponse = jsx:encode(#{error => "Failed to ping logic node"}),
            Req = cowboy_req:reply(500, #{<<"content-type">> => <<"application/json">>}, ErrorResponse, Req0),
            {fail, Req, _Opts}
    end.
