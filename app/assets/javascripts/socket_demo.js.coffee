window.SocketDemo = (path) ->
  if path? and _.isString(path) and path.match /[a-z0-9A-Z-_]*/
    url = Cartridge.config.SOCKET_URL + '/' + path
  else
    url = Cartridge.config.SOCKET_URL

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
