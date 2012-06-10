# just controls the canvas
class Cartridge.UI
  constructor: ->
    @canvas   = document.getElementById('game-canvas')
    @context  = @canvas.getContext('2d')
    @canvas.width  = '620'
    @canvas.height = '465'

