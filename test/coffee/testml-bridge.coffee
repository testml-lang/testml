require 'testml/bridge'

module.exports =
class TestMLBridge extends TestML.Bridge

  hash_lookup: (hash, key)->
    hash[key]

  get_env: (name)->
    process.env[name]

  add: (x, y)->
    x + y

  sub: (x, y)->
    x - y

  cat: (x, y)->
    x + y

  mine: ->
    new class Mine

  str_nums: (str)->
    _.map _.split(str, ' '), (x)-> Number x

