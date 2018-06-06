require 'testml/bridge'

require 'rotn'

module.exports =
class TestMLBridge extends TestML.Bridge
  rot: (input, n)->
    rotn = new RotN input
    rotn.rot(n)
    rotn.string
