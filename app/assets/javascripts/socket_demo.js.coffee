window.SocketDemo = (socket_url) ->
  ws = new WebSocket socket_url
  ws.onopen = (evt) ->
    $('#status').text('connected')
  ws.onmessage = (evt) ->
    console.log("received message!")
    try
      data = JSON.parse(evt.data)
      $("#messages").append("<p>" + data.message + "</p>")
    catch ex
      console.error ex.message
    console.dir(evt)
  console.log("setup")
