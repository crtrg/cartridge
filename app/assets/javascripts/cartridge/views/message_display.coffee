class Cartridge.Views.MessageDisplay extends Backbone.View
  initialize: (options) ->
    @cartridge = options.cartridge
    @collection.on 'reset', @render, this
    @collection.on 'add', @addMessage, this
    @render()

  render: ->
    console.log 'messages...'
    @$el.empty()
    @collection.each (message) =>
      @addMessage(message)

  addMessage: (message) ->
    console.log 'add message', message

    if message.get('username') == 'system'
      cls = 'system'
    else if message.get('user_id').toString() == @cartridge.id.toString()
      cls = 'current'
    else
      cls = 'other'

    @$el.append """
      <p>
        <small class='#{cls}'>#{ message.get('username') }</small><br>
        #{ message.get('message') }
      </p>
    """

    # too many secrets
    $('#chat-wrapper').scrollTop @$el.height()
