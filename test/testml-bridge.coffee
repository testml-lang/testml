require 'testml/bridge'

module.exports = class TestMLBridge extends TestML.Bridge
  add: (a, b)->
    Number(a) + Number b

  sub: (a, b)->
    a - b
