module.exports =
class TestML.StdLib
  constructor: (@run)->

  add: (x, y)-> x + y

  block: (selector)->
    @run.blocks[selector]

  bool: (any)->
    Boolean any

  cat: (str...)->
    str.join ''

  count: (list)->
    list[0].length

  error: (error='')->
    type = @run.get_type(error)
    switch
      when type == 'str' then ['!', error]
      when type == 'error' then error[1]
      else throw "Bad argument passed to Error: '#{error}'"

  env: -> [process.env]

  false: -> false

  flat: (list, depth=9999999999)->
    _.flattenDepth list, depth

  head: (list)->

  join: (list, separator=' ')->
    _.join list[0], separator

  lines: (text)->
    text = text.replace /\n$/, ''
    [text.split /\n/]

  null: -> null

  num: (any)->
    Number any

  pairs: (list)->
    _.chunk(list, 2)

  split: (string, delim=/\s+/, limit=9999999999)->
    [_.split(string, delim, limit)]

  str: (any)->
    String any

  text: (list)->
    [list[0]..., ''].join '\n'

  throw: (error='')->
    throw error

  true: -> true

  type: (object)->
    @run.get_type object
