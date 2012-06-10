class DemoGame
  constructor: (@cartridge) ->
    @setMyLocation(0,0)

    @cartridge.on 'change', @draw, this

    # setInterval _.bind(@tick, this), 100 # Math.floor(Math.random() * 3000 + 1000)

    update_ui = _.throttle( ((evt) => @updateUI(evt)), 60 )
    $(@canvas).on 'mouseover', (evt) ->
      console.log 'updating'
      update_ui evt

    @ui = @cartridge.ui
    @context = @ui.context
    @canvas  = @ui.canvas

  tick: ->
    x = Math.floor(Math.random() * (@canvas.width - 30))
    y = Math.floor(Math.random() * (@canvas.height - 30))
    @setMyLocation(x, y)

  updateUI: (evt) ->
    x = evt.pageX
    y = evt.pageY
    @setMyLocation(x, y)

  setMyLocation: (x,y) ->
    @cartridge.set @cartridge.id,
      x: x
      y: y

  draw: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    @cartridge.each (object, id) =>
      # console.log('draw', id, object)
      if id == @cartridge.id
        @context.fillStyle = '#0f0'
        @drawShape object.x, object.y, 30
      else
        @context.fillStyle = '#00f'
        @drawShape object.x, object.y, 10

  drawShape: (x, y, w) ->
    @context.fillRect x, y, w, w

window.DemoGame = DemoGame
