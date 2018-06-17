# Log a message with a color.
global.log = (message='', color, explanation) ->
  console.log (color or reset) + message + reset + ' ' + (explanation or '')
# Easy print
global.say = console.log
# Debugging
global.jjj = ->
  console.log JSON.stringify arguments
  process.exit 1
global.yyy = (a)->
  yaml = require 'js-yaml'
  console.log yaml.dump a
  return a
global.xxx = ->
  console.log.apply console, arguments
  process.exit 1

fs            = require 'fs'
path          = require 'path'
CoffeeScript  = require 'coffeescript'
{exec}        = require 'child_process'

# ANSI Terminal Colors.
enableColors = no
unless process.platform is 'win32'
  enableColors = not process.env.NODE_DISABLE_COLORS

bold = red = green = reset = ''
if enableColors
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'

start_time  = Date.now()
test_file   = null
pass_count  = 0
failures    = []

global[name] = func for name, func of require 'assert'

# Convenience aliases.
global.CoffeeScript = CoffeeScript

# Our test helper function for delimiting different test cases.
global.test = (description, fn) ->
  try
    fn.test = {description, test_file}
    fn.call(fn)
    pass_count++
  catch e
    global.color = red
    failure =
      filename: test_file
      message: e.message
    if typeof e is 'string'
      failure.message = e
    else if typeof e is 'object'
      for k, v in e
        failure[k] = v
    failure.description = description if description?
    failure.source = fn.toString() if fn.toString?
    failures.push failure

# See http://wiki.ecmascript.org/doku.php?id=harmony:egal
egal = (a, b) ->
  if a is b
    a isnt 0 or 1/a is 1/b
  else
    a isnt a and b isnt b

# A recursive functional equivalence helper; uses egal for testing equivalence.
arrayEgal = (a, b) ->
  if egal a, b then yes
  else if a instanceof Array and b instanceof Array
    return no unless a.length is b.length
    return no for el, idx in a when not arrayEgal el, b[idx]
    yes

global.eq      = (a, b, msg) -> ok egal(a, b), msg
global.arrayEq = (a, b, msg) -> ok arrayEgal(a,b), msg

# When all the tests have run, collect and print errors.
# If a stacktrace is available, output the compiled function source.
process.on 'exit', ->
  time = ((Date.now() - start_time) / 1000).toFixed(2)
  if not failures.length
    log "Passed #{pass_count} tests in #{time} seconds#{reset}.", green
    return

  log "Passed #{pass_count} and Failed #{failures.length} tests in #{time} seconds:", red
  num = 1
  for fail in failures
    log Array(80).join '-'
    log "Failure ##{num++}:", red
    log "  Test File: #{fail.filename}"
    log "  Test Desc: #{fail.description}"
    log "  Error Msg: #{fail.message}"
#     match = fail.stack?.match(new RegExp(fail.file+":(\\d+):(\\d+)"))
#     match = fail.stack?.match(/on line (\d+):/) unless match
#     [match, line, col] = match if match
#     log "  #{fail.description}", red if fail.description
#     log "  #{fail.stack}", red if fail.stack
#     log "  #{fail.filename}: line #{line ? 'unknown'}, column #{col ? 'unknown'}", red
#     log "  #{fail.source}" if fail.source
  return

# Run every test requested, recording failures.
exports.run = (paths) ->
  paths ?= process.argv.slice(4)

  for file in paths
    test_file = filename = file
    code = String fs.readFileSync filename
    global.color = green
    try
      require.main = {}
      CoffeeScript.run code, {filename}
    catch error
      # say error.code
      # say error.name
      # say error.stack
      global.color = red
      failures.push {
        filename: filename
        message: error.message
        description: error.code
      }
    log "Running #{color}#{filename}#{reset}"

  return not failures.length
