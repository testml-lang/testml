module.exports =
class TestML.StdLib
  true: ->
    true

  false: ->
    false

  type: (o)->
    switch
      when _.isString o then 'string'
      when _.isNumber o then 'number'
      when _.isArray o then 'list'
      when _.isRegExp o then 'regex'
      when _.isBoolean o then 'bool'
      else die "Can't determine type #{o}"

# vim: ft=coffee sw=2:
