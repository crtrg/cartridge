# mimics IO
class Cartridge.Chat
  constructor: (@chat_socket, @id) ->
    _.extend(this, Backbone.Events)
    @messages = new Cartridge.Collections.Messages
    @players  = new Cartridge.Collections.Players
    @page     = new Cartridge.Page(this)

    @chat_socket.onmessage = (event) =>
      data = JSON.parse(event.data)
      switch data.method
        when 'init'
          @players.reset  data.players
          @messages.reset data.messages
        when 'system'
          # a new system message received
          Cartridge.log '[Page] system message received'
          Cartridge.dir data
          @messages.add username: 'system', user_id: 0, message: data.message
        when 'chat'
          Cartridge.log '[Page] chat message received'
          Cartridge.dir data
          @messages.add username: data.username, user_id: data.user_id, message: data.message
        when 'players'
          Cartridge.log "[Page] updated players"
          @players.reset data.players
        when 'delete'
          delete @state[data.args[0]]
        else
          Cartridge.log "[Page] can't handle #{data.method}"

  chat: (message) ->
    @chat_socket.send JSON.stringify(
      method: 'chat'
      args: [message]
    )

