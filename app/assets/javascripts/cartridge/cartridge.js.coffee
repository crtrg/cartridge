class Cartridge.UI
  constructor: ->
    @canvas   = document.getElementById('game-canvas')
    @context  = @canvas.getContext('2d')

    @canvas.width  = '460'
    @canvas.height = '460'

Cartridge.boot = (game) ->
  Cartridge.log('booting', game)
  ws       = new WebSocket Cartridge.config().socketUrl
  userId   = Cartridge.config().userId

  ws.onopen = (evt) ->
    $('#status').text('connected')
    new game(new Cartridge.IO(ws, userId))

Cartridge.config = (options) ->
  if options
    Cartridge._config = options
  else
    Cartridge._config

