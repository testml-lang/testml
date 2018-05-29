require 'testml/bridge'

module.exports =
class TestMLBridge extends TestML.Bridge

  hash_lookup: (hash, key)->
    hash[key]

  get_env: (name)->
    process.env[name]

# vim: ft=coffee sw=2:
