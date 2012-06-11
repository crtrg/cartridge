class Cartridge.IO
  constructor: (@game_socket, @id) ->
    _.extend(this, Backbone.Events)
    @state    = {}
    @players  = new Cartridge.Collections.Players
    @ui       = new Cartridge.UI(this)

    @game_socket.onmessage = (event) =>
      data = JSON.parse(event.data)
      switch data.method
        when 'init'
          @state = data.state
          @players.reset data.players
          @trigger('init')
        when 'system'
          # a new system message received
          Cartridge.log '[IO] system message received'
          Cartridge.dir data.message

          @trigger 'system', data.message
        when 'players'
          Cartridge.log "[IO] updated players with"
          Cartridge.dir data.players

          @players.reset data.players
        when 'set'
          @state[data.args[0]] = data.args[1]
          @trigger('change')
        when 'delete'
          delete @state[data.args[0]]

  set: (key, value) ->
    @game_socket.send JSON.stringify(
      method: 'set'
      args: [key, value]
    )

  each: (fn, context) ->
    _(@state).each(fn, context)

