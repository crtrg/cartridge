# initialize the cartridge engine
Cartridge.boot = (game) ->
  # console.log('booting', game)
  ws       = new WebSocket Cartridge.config().socketUrl
  userId   = Cartridge.config().userId

  ws.onopen = (evt) ->
    $('#status').text "connected as #{userId}"
    new game(new Cartridge.IO(ws, userId))

Cartridge.config = (options) ->
  if options
    Cartridge._config = options
  else
    Cartridge._config

