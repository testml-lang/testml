{pegex} = require '../lib/pegex'
require './lib/parse-testml-data'
YAML = require 'js-yaml'

parse = (grammar, input) ->
  parser = pegex grammar
  Pegex.xxx = false
  parser.grammar.make_tree() unless parser.grammar.tree?
  Pegex.xxx = true
  parser.parse input

data = parse_testml_data '''
=== Single Regex - Single Capture
--- grammar
a: /x*(y*)z*<EOL>/
--- input
xxxyyyyzzz
--- ast
a: yyyy

=== Single Regex - Multi Capture
--- grammar
a: /(x*)(y*)(z*)<EOL>/
--- input
xxxyyyyzzz
--- ast
a:
- xxx
- yyyy
- zzz

=== Single Regex - No Capture
--- grammar
a: /x*y*z*<EOL>/
--- input
xxxyyyyzzz
--- ast
a: []

=== A subrule
--- grammar
a: <b> /(y+)/ <EOL>
b: /(x+)/
--- input
xxxyyyy
--- ast
a:
- b: xxx
- yyyy

=== Multi match regex in subrule
--- grammar
a: <b>
b: /(x*)y*(z*)<EOL>/
--- input
xxxyyyyzzz
--- ast
a:
  b:
  - xxx
  - zzz

=== Any rule group
--- grammar
a: ( <b> | <c> )
b: /(bleh)/
c: /(x*)y*(z*)<EOL>?/
--- input
xxxyyyyzzz
--- ast
a:
  c:
  - xxx
  - zzz

=== + Modifier
--- grammar
a: ( <b> <c> )+ <EOL>
b: /(x*)/
c: /(y+)/
--- input
xxyyxy
--- ast
a:
- - - b: xx
    - c: yy
  - - b: x
    - c: y

=== Empty regex group plus rule
--- grammar
a: <b>* <c> <EOL>
b: /xxx/
c: /(yyy)/
--- input
xxxyyy
--- ast
a:
- []
- c: yyy


=== Part of Pegex Grammar
--- grammar
# This is the Pegex grammar for Pegex grammars!
grammar: ( <comment>* <rule_definition> )+ <comment>*
rule_definition: /<WS>*/ <rule_name> /<COLON><WS>*/ <rule_line>
rule_name: /(<ALPHA><WORD>*)/
comment: /<HASH><line><EOL>/
line: /<ANY>*/
rule_line: /(<line>)<EOL>/

--- input
# This is the Pegex grammar for Pegex grammars!
grammar: ( <comment>* <rule_definition> )+ <comment>*
rule_definition: /<WS>*/ <rule_name> /<COLON><WS>*/ <rule_line>
--- ast
grammar:
- - - []
    - rule_definition:
      - rule_name: grammar
      - rule_line: ( <comment>* <rule_definition> )+ <comment>*
  - - []
    - rule_definition:
      - rule_name: rule_definition
      - rule_line: /<WS>*/ <rule_name> /<COLON><WS>*/ <rule_line>
- []


=== Rule to Rule to Rule
--- grammar
a: <b>
b: <c>*
c: <d> <EOL>
d: /x(y)z/
--- input
xyz
xyz
--- ast
a:
  b:
  - c:
    - d: y
  - c:
    - d: y
'''

tests = []
for t in data
  continue if t.SKIP?
  if t.ONLY?
    tests = [t]
    break
  tests.push t
  break if t.LAST?

for t in tests
  test t.label, ->
    deepEqual parse(t.grammar, t.input), YAML.load t.ast
