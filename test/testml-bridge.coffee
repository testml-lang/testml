require 'testml/bridge'

module.exports =
class TestMLBridge extends TestML.Bridge
  add: (x, y)->
    x + y

  sub: (x, y)->
    x - y

  cat: (x, y)->
    x + y
