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

  false: -> false

  flat: (list, depth=9999999999)->
    _.flattenDepth list, depth

  head: (list)->

  join: (list, separator=' ')->
    _.join list, separator

  lines: (text)->
    text = text.replace /\n$/, ''
    [text.split /\n/]

  null: -> null

  num: (any)->
    Number any

  pairs: (list)->
    _.chunk(list, 2)

  split: (string, delim=/\s+/, limit=0)->
    _.split(string, delim, limit)

  str: (any)->
    String any

  text: (list)->
    [list[0]..., ''].join '\n'

  true: -> true

  type: (object)->
    @run.get_type object

# vim: ft=coffee sw=2:
