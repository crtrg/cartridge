%% Feel free to use, reuse and abuse the code in this file.

-module(cowboy_examples).
-behaviour(application).
-export([start/0, start/2, stop/1]).

start() ->
  application:start(crypto),
  application:start(public_key),
  application:start(ssl),
  application:start(cowboy),
  application:start(cowboy_examples).

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
  cowboy:start_listener(my_https_listener, 100,
    cowboy_ssl_transport, [
      {port, 8443}, {certfile, "priv/ssl/cert.pem"},
      {keyfile, "priv/ssl/key.pem"}, {password, "cowboy"}],
    cowboy_http_protocol, [{dispatch, Dispatch}]
  ),
  cowboy_examples_sup:start_link().

stop(_State) ->
  ok.
