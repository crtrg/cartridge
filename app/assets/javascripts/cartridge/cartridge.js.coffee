# initialize the cartridge engine
Cartridge.boot = (game) ->
  # console.log('booting', game)
  ws       = new WebSocket Cartridge.config().socketUrl
  userId   = Cartridge.config().userId
  io       = new Cartridge.IO(ws, userId)
  io.on 'init', =>
    console.log('init!, booting')
    new game(io)

  ws.onopen = (evt) ->
    $('#game-status').text "connected as #{userId}"

  ws.onclose = (evt) ->
    $('#game-status').text 'disconnected. reconnecting ...'
    setTimeout ->
      Cartridge.boot(game)
    , 500

# connect to chat socket and fire up UI
Cartridge.startUI = ->
  ws       = new WebSocket Cartridge.config().chatUrl
  userId   = Cartridge.config().userId

  ws.onopen = (evt) ->
    $('#chat-status').text "connected to chat as #{userId}"
    new Cartridge.Chat(ws, userId)

  ws.onclose = (evt) ->
    $('#chat-status').text 'disconnected from chat. reconnecting ...'
    setTimeout ->
      Cartridge.startUI()
    , 500

Cartridge.config = (options) ->
  if options
    Cartridge._config = options
  else
    Cartridge._config

