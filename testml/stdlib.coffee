module.exports =
class TestML.StdLib
  constructor: (@run)->

  add: (x, y)-> x + y

  block: (selector)->
    @run.blocks[selector]

  cat: (str...)->
    str.join ''

  count: (list)->
    list.length

  false: -> false

  flat: (list, depth=9999999999)->
    _.flattenDepth list, depth

  head: (list)->

  join: (list, separator=' ')->
    _.join list, separator

  lines: (text)->
    text = text.replace /\n$/, ''
    text.split /\n/

  null: -> null

  number: (any)->
    Number any

  pairs: (list)->
    _.chunk(list, 2)

  split: (string, delim=/\s+/, limit=0)->
    _.split(string, delim, limit)

  string: (any)->
    String any

  text: (list)->
    [list..., ''].join '\n'

  true: -> true

  type: (args...)->
    _.join _.map(args, (o)->
      switch
        when _.isString o then 'string'
        when _.isNumber o then 'number'
        when _.isArray o then 'list'
        when _.isRegExp o then 'regex'
        when _.isBoolean o then 'bool'
        when _.isNil o then 'null'
        else die "Can't determine type #{o}"
    ), '+'

# vim: ft=coffee sw=2:
