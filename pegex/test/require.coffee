modules = [
  'pegex'
  'pegex/compiler'
  'pegex/grammar'
  'pegex/input'
  'pegex/module'
  'pegex/optimizer'
  'pegex/parser'
  'pegex/receiver'
  'pegex/tree'
  'pegex/tree/wrap'
  'pegex/grammar/atoms'
  'pegex/parser/indent'
  'pegex/pegex/ast'
  'pegex/pegex/grammar'
]

for module in modules
  test "Can require #{module}", ->
    ok require "../lib/#{module}"
