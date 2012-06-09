class Cartridge.Views.PlayerListing extends Backbone.View
  initialize: ->
    @collection.on 'reset', =>
      @render()

  render: ->
    console.log 'rendering', @collection

    @$el.empty()
    @collection.each (player) =>
      console.dir player
      @$el.append "<li>#{ player.get('username') }</li>"

    this
