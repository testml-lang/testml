@global = @
@exports = {}
@require = ->
@say = console.log

# @.require = (path)=>
#   @.exports = {}
#   path = path.replace /^(\.\.?\/)+/, ''
#   path = path.replace /\//, '.'
#   console.log path
#   unless eval path
#     console.log arguments.callee.caller
#     throw "Class #{path} was not provided"
