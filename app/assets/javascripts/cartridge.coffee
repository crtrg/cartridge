Cartridge.boot = (game) ->
  Cartridge.log('booting', game)
  instance = null
  ws = new WebSocket Cartridge.config().socketUrl
  userId = Cartridge.config().userId
  ws.onopen = (evt) ->
    $('#status').text('connected')
    instance = new game(new Cartridge.IO(ws, userId))

Cartridge.config = (options) ->
  if options
    Cartridge._config = options
  else
    Cartridge._config

