window.SocketDemo = () ->
  url = Cartridge.config().socketUrl
  ws = new WebSocket url
  ws.onopen = (evt) ->
    $('#status').text('connected')
  ws.onmessage = (evt) ->
    Cartridge.log("received message!")
    try
      data = JSON.parse(evt.data)
      $("#messages").append("<p>" + data.message + "</p>")
    catch ex
      Cartridge.error ex.message
    Cartridge.dir(evt)
  console.log("setup")
