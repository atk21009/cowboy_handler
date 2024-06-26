-module(package_handler).

-export([init/2]).

init(Req0, Opts) -> 
    Method = cowboy_req:method(Req0), % [GET, POST, ...] 
    Path = cowboy_req:path(Req0), % Path of url
    {ok,Data,_} = cowboy_req:read_body(Req0), % Body if any
    DecodedData = case Data of
        <<>> -> {}; % pass empty tuple
        _ -> jsx:decode(Data) % decode data
    end,

    % pass to server
    Res = erpc:call('logic@logic.taylor58.dev', package_server, package, [Method, Path, DecodedData]),
    case Res of 
        {ok, Response} ->
            % send response to user
            io:format("Response: ~p~n", [Response]),
            ResponseData =  jsx:encode(Response),
            io:format("Response Encoded: ~p~n", [ResponseData]),
            Req = cowboy_req:reply(200, #{
                <<"content-type">> => <<"text/json">>
            }, ResponseData, Req0),
            {ok, Req, Opts};
        {fail, Reason} ->
            Req = cowboy_req:reply(400, #{
                <<"content-type">> => <<"text/json">>
            }, Reason, Req0),
            {fail, Req, Opts}
    end.