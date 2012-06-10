# controls chrome
class Cartridge.Page
  constructor: (@crtrg) ->
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

      Cartridge.log "[Page] sending chat #{ $('#chat-form input').val() }"
      @crtrg.chat $('#chat-form input').val()
      $('#chat-form input').val('')

      return false

