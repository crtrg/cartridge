class Cartridge.IO
  constructor: (@socket, @id) ->
    _.extend(this, Backbone.Events)
    @state    = {}
    @players  = new Cartridge.Collections.Players
    @messages = new Cartridge.Collections.Messages
    @ui       = new Cartridge.UI(this)

    @socket.onmessage = (event) =>
      data = JSON.parse(event.data)
      # console.log("received '#{data["method"]}' with", data)
      switch data.method
        when 'init'
          @state = data.state
          @players.reset data.players
        when 'system'
          # a new system message received
          console.log 'system message received', data.message
          @messages.add username: 'system', message: data.message
        when 'chat'
          @messages.add username: data.username, user_id: data.user_id, message: data.message
        when 'players'
          console.log "updated players with", data.players
          @players.reset data.players
        when 'set'
          @state[data.args[0]] = data.args[1]
          @trigger('change')
        when 'delete'
          delete @state[data.args[0]]
        else
          console.log("Can't handle", data.method, data, typeof(data))

  set: (key, value) ->
    # console.log('Cartridge::IO#set', arguments)
    @socket.send JSON.stringify(
      method: 'set'
      args: [key, value]
    )

  each: (fn, context) ->
    _(@state).each(fn, context)

  chat: (message) ->
    @socket.send JSON.stringify(
      method: 'chat'
      args: [message]
    )

