class TestMLError
  constructor: (@msg)->

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

  add: (x, y)-> x + y

  block: (selector)->
    for block in @run.data
      if block.label == selector
        return block

  blocks: ->
    @run.data

  bool: (any)->
    Boolean any

  cat: (str...)->
    str.join ''

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

  false: -> false

  flat: (list, depth=9999999999)->
    _.flattenDepth list, depth

  head: (list)->
    _.head list

  identity: (value)->
    value

  join: (list, separator=' ')->
    _.join list, separator

  length: (str)->
    str.length

  lines: (text)->
    text = text.replace /\n$/, ''
    text.split /\n/

  null: -> null

  num: (any)->
    Number any

  pairs: (list)->
    _.chunk(list, 2)

  say: -> ___ 'write string to stdout'

  split: (string, delim=/\s+/, limit=9999999999)->
    _.split string, delim, limit

  str: (any)->
    String any

  tail: (list)->
    _.tail list

  text: (list)->
    [list..., ''].join '\n'

  throw: (error='')->
    throw error

  true: -> true

  type: (value)->
    @run.get_type @run.cook value

  warn: -> ___ 'write string to stderr'
