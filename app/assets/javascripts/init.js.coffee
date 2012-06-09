
# things that have to exist before everything else in Cartridge

window.Cartridge ||= {}

# `Cartridge.namespace('First').namespace('Second').value = newValue;` should always work.
Cartridge.namespace = (args...) ->
  # root
  obj = Cartridge

  while ns = args.shift()
    obj[ns] ||= {}
    obj = obj[ns]

  # return final namespace
  return obj

Cartridge.log = (message, args...) ->
  _log = (s) ->
    if window.console
      console.log(s) # ff, chrome
    else if typeof Debug == 'object'
      Debug.writeln(s) # IE
    else if typeof opera == 'opera'
      opera.postError(s) # Opera

  # console.log message
  if window.DEBUG
    if _.isFunction(message)
      message()
    else
      if args.length > 0
        _log message, args
      else
        _log message

Cartridge.dir = (object) ->
  console.dir object if console? and window.DEBUG

Cartridge.error = (message) ->
  console.error message if console?
