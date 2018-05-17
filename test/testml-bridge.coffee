require 'testml/bridge'

module.exports = class TestMLBridge extends TestML.Bridge
  add: (a, b)->
    a + b

  sub: (a, b)->
    a - b
