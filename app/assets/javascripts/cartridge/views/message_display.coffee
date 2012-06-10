class Cartridge.Views.MessageDisplay extends Backbone.View
  messageTemplate: _.template("""
      <div class='message'>
        <div class='username <%= cls %>'>
          <%= username %>
        </div>
        <%= message %>
      </div>
  """)

  renderMessage: (json) ->
    @messageTemplate json

  initialize: (options) ->
    @cartridge = options.cartridge
    @collection.on 'reset', @render, this
    @collection.on 'add', @addMessage, this
    @render()

  render: ->
    @$el.empty()
    @collection.each (message) =>
      @addMessage(message)

  addMessage: (message) ->
    if message.get('username') == 'system'
      cls = 'system'
    else if message.get('user_id').toString() == @cartridge.id.toString()
      cls = 'current'
    else
      cls = 'other'

    json =
      cls: cls
      message: message.get('message')
      username: message.get('username')

    @$el.append @renderMessage(json)

    # too many secrets
    $('#chat-wrapper').scrollTop @$el.height()
