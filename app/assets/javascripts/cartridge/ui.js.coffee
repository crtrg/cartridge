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
    @playerListing.render()

    @chat
