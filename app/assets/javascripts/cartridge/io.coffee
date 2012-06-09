class Cartridge.IO
  constructor: (@socket, @id) ->
    _.extend(this, Backbone.Events)
    @state = {}
    @socket.onmessage = (event) =>
      data = JSON.parse(event.data)
      console.log('received', event, event.data, data)
      switch data.method
        when 'init'
          @state = data.state
          @players = data.players
        when 'system'
          # a new system message received
          console.log 'system message received', data.message
        when 'set'
          @state[data.args[0]] = data.args[1]
          @trigger('change')
        when 'delete'
          delete @state[data.args[0]]
        else
          console.log("Can't handle", data)

  set: (key, value) ->
    Cartridge.log('Cartridge::IO#set', arguments)
    @socket.send JSON.stringify(
      method: 'set'
      args: [key, value]
    )

  each: (fn, context) ->
    _(@state).each(fn, context)
