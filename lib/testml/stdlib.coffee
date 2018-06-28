class TestMLError
  constructor: (@msg)->


# For stubbing out possible methods to support:
___ = (desc='')->
  # Get caller name:
  name = 'unknown'
  try
    Error.prepareStackTrace = (_, stack)->
      name = stack[1].getFunctionName()
    Error.captureStackTrace new Error

  throw "Unimplemented StdLib method: '#{name}' - #{desc}"


module.exports =
class TestML.StdLib
  constructor: (@run)->

  argv: ->
    process.argv[2..]

  block: (selector)->
    return @run.block if not selector?
    for block in @run.data
      if block.label == selector
        return block
    null

  blocks: ->
    _.clone @run.data

  bool: (value)->
    value != undefined && value != null && value != false

  cat: (strings...)->
    strings = strings[0] if strings[0] instanceof Array
    strings.join ''

  count: (list)->
    list.length

  error: (error='')->
    new TestMLError error

  env: ->
    @_env ||= do ->
      env = {}
      for key, value of process.env
        env[key] = value
      env

  false: ->
    false

  first: (list)->
    _.first list

  flat: (list, depth=9999999999)->
    _.flattenDepth list, depth

  hash: (values...)->
    hash = {}
    for key, val in values
      hash[key] = val
    hash

  head: (list)->
    _.head list

  identity: (value)->
    value

  import: -> ___ 'Runtime .tml import (possibly data only)'

  join: (list, separator=' ')->
    _.join list, separator

  last: (list)->
    _.last list

  length: (str)->
    str.length

  lines: (text)->
    text = text.replace /\n$/, ''
    text.split /\n/

  list: (values...)->
    values

  msg: (error)->
    error.msg

  none: ->
    return

  null: ->
    null

  num: (value)->
    Number value

  pop: (list)->
    list.pop()
    list

  regex: (pattern, flags='')->
    new RegExp pattern, flags

  say: (msg)->
    msg = "#{msg}\n" unless msg.match /\n$/
    @run.out msg

  shift: (list)->
    list.shift()
    list

  split: (string, delim=/\s+/, limit=9999999999)->
    _.split string, delim, limit

  str: (value)->
    String value

  sum: (list...)->
    list = list[0] if list[0] instanceof Array
    _.sum list

  tail: (list)->
    _.tail list

  text: (list)->
    [list..., ''].join '\n'

  throw: (error='')->
    @run.thrown = new TestMLError error
    0

  true: ->
    true

  type: (value)->
    @run.type @run.cook value

  unshift: (list, values...)->
    list.unshift values...
    list

  warn: (msg)->
    msg = "#{msg}\n" unless msg.match /\n$/
    @run.err msg

  #----------------------------------------------------------------------------
  eq: (x, y)-> ___ 'test if x == y'
  gt: (x, y)-> ___ 'test if x > y'
  ge: (x, y)-> ___ 'test if x >= y'
  lt: (x, y)-> ___ 'test if x < y'
  le: (x, y)-> ___ 'test if x <= y'
