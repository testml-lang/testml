# From https://github.com/dmajda/pegjs/blob/master/examples/arithmetics.pegjs
# /*
#  * Classic example grammar, which recognizes simple arithmetic expressions like
#  * "2*(3+4)". The parser generated from this grammar then computes their value.
#  */
# 
# start
#   = additive
# 
# additive
#   = left:multiplicative "+" right:additive { return left + right; }
#   / multiplicative
# 
# multiplicative
#   = left:primary "*" right:multiplicative { return left * right; }
#   / primary
# 
# primary
#   = integer
#   / "(" additive:additive ")" { return additive; }
# 
# integer "integer"
#   = digits:[0-9]+ { return parseInt(digits.join(""), 10); }

# Here is the closest Pegex analog:
{pegex} = require '../lib/pegex'

grammar = """
# start: additive     # Not needed. First rule is start rule by default.
additive:
  ( multiplicative <PLUS> additive )
  | multiplicative
multiplicative:
  ( primary <STAR> multiplicative )
  | primary
primary:
  integer
  | ( <LPAREN> additive <RPAREN> )
integer:
  /(<DIGIT>+)/
"""

class code
  got_integer: (int) -> Number int
  got_additive: (pair) ->
    return pair unless pair instanceof Array
    [a, b] = pair
    a + b
  got_multiplicative: (pair) ->
    return pair unless pair instanceof Array
    [a, b] = pair
    a * b

# Code to test the parser.
test = (expression) ->
  result = pegex(grammar, {receiver: (new code)}).parse expression
  console.log "#{expression} = #{result}"

# This passes:
test '(2+3)*4'
test '2+3*4'
# This fails:
test '2+(3*4)'
