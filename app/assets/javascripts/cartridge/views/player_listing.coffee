class Cartridge.Views.PlayerListing extends Backbone.View
  initialize: (options) ->
    @collection.on 'reset', @render, this
    @render()
    @cartridge = options.cartridge

    @template = _.template """
      <li class='<%= cls %>'>
        <%= username %>
      </li>
    """

  render: ->
    @$el.empty()
    @collection.each (player) =>
      cls = if player.id.toString() == @cartridge.id.toString() then 'current' else 'other'
      @$el.append "<li class='#{cls}'>#{ player.get('username') }</li>"

    $('#user-listing-wrapper').scrollTop @$el.height()
    $('#user-count').text Cartridge.pluralize(@collection.length, 'user') + ' connected'

    this

