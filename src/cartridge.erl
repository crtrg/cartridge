-module(cartridge).
-behaviour(application).
-export([start/0, start/2, stop/1]).

start() ->
  application:start(cowboy),
  application:start(cartridge).

start(_Type, _Args) ->
  Dispatch = [
    {'_', [
        {[<<"io">>], websocket_handler, []},
        {[<<"public">>, '...'], cowboy_http_static, [
            {directory, <<"./public">>},
            {mimetypes, [
                {<<".html">>, [<<"text/html">>]},
                {<<".js">>,   [<<"application/javascript">>]},
                {<<".css">>,  [<<"text/css">>]}
              ]}
          ]}
      ]}
  ],
  cowboy:start_listener(my_http_listener, 100,
    cowboy_tcp_transport, [{port, 8080}],
    cowboy_http_protocol, [{dispatch, Dispatch}]
  ),
  cartridge_sup:start_link().

stop(_State) ->
  ok.
