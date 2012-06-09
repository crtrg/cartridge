# just controls the canvas
class Cartridge.UI
  constructor: (@crtrg) ->
    @canvas   = document.getElementById('game-canvas')
    @context  = @canvas.getContext('2d')
    @canvas.width  = '460'
    @canvas.height = '460'

    # set up view components
    @playerListing = new Cartridge.Views.PlayerListing
      collection: @crtrg.players
      id: 'user-listing'
      el: $('#user-listing')
      cartridge: @crtrg

    @messageDisplay = new Cartridge.Views.MessageDisplay
      collection: @crtrg.messages
      id: 'message-listing'
      el: $('#message-listing')
      cartridge: @crtrg

    $('#chat-form').on 'submit', (evt) =>
      evt.preventDefault()
      evt.stopPropagation()

      @crtrg.chat $('#chat-form input').val()
      $('#chat-form input').val('')

      return false

