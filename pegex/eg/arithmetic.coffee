# This is a calulator parser, that handles the following:
# * Calculations involving:
#   * Positive integers
#   * `+ - * / ^` operators
#   * Precedence and associativity
#   * Parenthetical grouping
# * Whitespace separation (or not)
# * The receiver class evaluates the expression and returns the result.
#
# Originally inspired by:
#   https://github.com/dmajda/pegjs/blob/master/examples/arithmetics.pegjs

{pegex} = require '../lib/pegex'
require '../lib/pegex/receiver'

calculator_pegex_grammar = """
# This is a grammar that will match an arithmetic expression like:
#    -5 * ( 23 - 2^3)
# Pegex.Parser will apply this grammar to an input and pass the matched data
# on to a receiver object. A receiver class called Calculator (below) will
# turn the parse events into a RPN (reverse polish notation) stack and
# evaluate it. The data that gets "received" is parenthesized in regex
# captures below.

# An expression is a list of one or more values separated by operators
expr: value (op value)*

# Capture an operator. One of: + - * / ^ (with optional whitespace)
op: /~([<PLUS><DASH><STAR><SLASH><CARET>])~/

# A value is a number or a parenthesized expression
value: num | group

# Capture a number: # -# #.# or -#.#
num: /(
  <DASH>?
  <DIGIT>+
  (:<DOT><DIGIT>+)?
)/

# Parenthesized expression (with option whitespace around the parens)
group:  /~<LPAREN>~/ expr /~<RPAREN>~/
"""

class Calculator extends Pegex.Receiver
  # Operator function, precedence and associativity table:
  operators =
    '+': f: 'add', p: 1, a: 'left'
    '-': f: 'sub', p: 1, a: 'left'
    '*': f: 'mul', p: 2, a: 'left'
    '/': f: 'div', p: 2, a: 'left'
    '^': f: 'exp', p: 3, a: 'right'

  # Cast the matched numeric Strings into actual Numbers
  got_num: (num) -> Number num

  # http://en.wikipedia.org/wiki/Shunting-yard_algorithm
  got_expr: (expr) ->
    tail = expr.pop()
    for elem in tail
      expr = expr.concat elem
    [out, ops] = [[],[]]
    out.push expr.shift()
    while expr.length
      op = expr.shift()
      {p, a} = operators[op]
      while ops.length
        p2 = operators[ops[0]].p
        break if p > p2 or p == p2 and a == 'right'
        out.push ops.shift()
      ops.unshift op
      out.push expr.shift()
    @flatten out.concat ops

  # Expression should now be an RPN array.
  final: (expr) ->
    @.rpn_expression = [].concat expr
    @evaluate expr

  evaluate: (expr) ->
    return expr[0] if expr.length == 1
    func = 'do_' + operators[expr.pop()].f
    val2 = @get_value expr
    @[func] @get_value(expr), val2

  get_value: (expr) ->
    if expr[expr.length - 1] instanceof Array
      @evaluate expr.pop()
    else if operators[expr[expr.length - 1]]
      @evaluate expr
    else
      expr.pop()

  do_add: (a, b) -> a + b
  do_sub: (a, b) -> a - b
  do_mul: (a, b) -> a * b
  do_div: (a, b) -> a / b
  do_exp: (a, b) -> Math.pow(a, b)


test = (input) ->
  receiver = new Calculator({})
  grammar = pegex calculator_pegex_grammar, {receiver}
  result = grammar.parse input
  console.log "#{input} = #{result}	RPN( #{receiver.rpn_expression} )"

test '2'
test '2 + (4 + 6) * 8'
test '2 * 4'
test '2 * 4 + 6'
test '2 + 4 * 6 + 1'
test '2 ^ 3 ^ 2'
test '2 ^ (3 ^ 2)'
test '2 * 2^3^2'
test '(2^5)^2'
test '2^5^2'
test '0*1/(2+3)-4^5'
test '2/0+1'
