class DemoGame
  constructor: (@cartridge) ->
    @setMyLocation(0,0)
    @cartridge.on('change', @draw, this)
    setInterval(_.bind(@tick, this), 5000)

  tick: ->
    x = Math.floor(Math.random()*100)
    y = Math.floor(Math.random()*100)
    @setMyLocation(x,y)

  setMyLocation: (x,y) ->
    @cartridge.set @cartridge.id,
      x: x
      y: y

  draw: ->
    @cartridge.each( (object, id) ->
      console.log('draw', id, object)
      @drawCircle(object.x, object.y, 10)
    )



window.DemoGame = DemoGame
