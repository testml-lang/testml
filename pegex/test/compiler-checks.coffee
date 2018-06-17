require '../lib/pegex/compiler'
require './lib/parse-testml-data'
YAML = require 'js-yaml'

compile = (grammar) ->
  compiler = new Pegex.Compiler
  tree = compiler.parse(grammar).combinate().tree
  delete tree['+toprule']
  tree

data = parse_testml_data '''
# XXX grammar needs blank line here, because of testml parser bug
=== Empty Grammar
--- grammar
--- yaml
{}

=== Simple Grammar
--- grammar
a: ( <b> <c>* )+
b: /x/
c: <x>

--- yaml
a:
  +min: 1
  .all:
  - .ref: b
  - +min: 0
    .ref: c
b:
  .rgx: x
c:
  .ref: x

=== Single Rule
--- grammar
a: <x>
--- yaml
a:
  .ref: x

=== Single Rule with no brackets
--- grammar
a: x
--- yaml
a:
  .ref: x

=== Single Rule With Trailing Quantifier
--- grammar
a: <x>*
--- yaml
a:
  +min: 0
  .ref: x

=== Single Rule With Trailing Quantifier (no angles)
--- grammar
a: x*
--- yaml
a:
  +min: 0
  .ref: x

=== Single Rule With Leading Assertion
--- grammar
a: =<x>
--- yaml
a:
  +asr: 1
  .ref: x

=== Single Regex
--- grammar
a: /x/
--- yaml
a:
  .rgx: x

=== Single Error
--- grammar
a: `x`
--- yaml
a:
  .err: x

=== Unbracketed All Group
--- grammar
a: <x> <y>
--- yaml
a:
  .all:
  - .ref: x
  - .ref: y

=== Unbracketed Any Group
--- grammar
a: /x/ | <y> | `z`
--- yaml
a:
  .any:
  - .rgx: x
  - .ref: y
  - .err: z

=== Bracketed All Group
--- grammar
a: ( <x> <y> )
--- yaml
a:
  .all:
  - .ref: x
  - .ref: y

=== Bracketed Group With Trailing Modifier
--- grammar
a: ( <x> <y> )?
--- yaml
a:
  +max: 1
  .all:
  - .ref: x
  - .ref: y

=== Bracketed Group With Leading Modifier
--- grammar
a: .( =<x> <y> )
--- yaml
a:
  -skip: 1
  .all:
  - +asr: 1
    .ref: x
  - .ref: y

=== Multiple Groups
--- grammar
a: ( <x> <y> ) ( <z> | /.../ )
--- yaml
a:
  .all:
  - .all:
    - .ref: x
    - .ref: y
  - .any:
    - .ref: z
    - .rgx: '...'

=== Whitespace in Regex
--- grammar
a: /<DOT>* (<DASH>{3})
    <BANG>   <BANG>
   /
--- yaml
a:
  .rgx: \\.*(\\-{3})!!

=== Directives
--- grammar
\\%grammar foo
\\%version 1.2.3

--- yaml
+grammar: foo
+version: 1.2.3

=== Multiple Duplicate Directives
--- grammar
\\%grammar foo
\\%include bar
\\%include baz

--- yaml
+grammar: foo
+include:
- bar
- baz

=== Grammar with leading comment
--- grammar
\\# Comment
a: 'a'

--- yaml
a:
  .rgx: a

=== Dashes in rule names
--- grammar
a-b: 'a'

--- yaml
a_b:
  .rgx: a

=== Escaping single quotes
--- grammar
a: /( '=' | '||=' )/

--- yaml
a:
  .rgx: (=|\\|\\|=)

=== Alias name rules
--- grammar
a: /( b )/
b: c
c: /d/

--- yaml
a:
  .rgx: (d)

=== Whitespace rule expansion in regex
--- grammar
a: / 'b' +
     'c' -
   /

--- yaml
a:
  .rgx: b\\s+c\\s*

=== More whitespace rule expansion in regex
--- grammar
a: /+ '==' +/

--- yaml
a:
  .rgx: \\s+==\\s+

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
    deepEqual compile(t.grammar), YAML.load t.yaml
