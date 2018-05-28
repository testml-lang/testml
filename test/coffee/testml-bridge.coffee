require 'testml/bridge'

module.exports =
class TestMLBridge extends TestML.Bridge

  hash_lookup: (hash, key)->
    hash[key]

# vim: ft=coffee sw=2:
