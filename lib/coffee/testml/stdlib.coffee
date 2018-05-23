module.exports =
class TestML.StdLib
  constructor: (@run)->

  block: (selector)->
    @run.blocks[selector]

  count: (list)->
    list.length

  false: ->
    false

  lines: (text)->
    text = text.replace /\n$/, ''
    text.split /\n/

  null: ->
    null

  text: (list)->
    [list..., ''].join '\n'

  true: ->
    true

  type: (o)->
    switch
      when _.isString o then 'string'
      when _.isNumber o then 'number'
      when _.isArray o then 'list'
      when _.isRegExp o then 'regex'
      when _.isBoolean o then 'bool'
      else die "Can't determine type #{o}"

# vim: ft=coffee sw=2:
