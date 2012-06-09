
# things that have to exist before everything else in Cartridge

window.Cartridge ||= {}
window.Cartridge =
  Models: {}
  Collections: {}
  Views: {}

# `Cartridge.namespace('First').namespace('Second').value = newValue;` should always work.
Cartridge.namespace = (args...) ->
  # root
  obj = Cartridge

  while ns = args.shift()
    obj[ns] ||= {}
    obj = obj[ns]

  # return final namespace
  return obj

Cartridge.log = () ->
  # console.log message
  if window.DEBUG
    console.log(arguments)

Cartridge.dir = (object) ->
  console.dir object if console? and window.DEBUG

Cartridge.error = (message) ->
  console.error message if console?
