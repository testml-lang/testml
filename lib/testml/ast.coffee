require('pegex').require 'tree'

class TestML.AST extends Pegex.Tree
  constructor: ->
    super()
    @code = []
    @data = []

  final: ->
    got =
      testml: '0.3.0'
      code: []
      data:[]

    for statement in @code
      if statement[0] == '()'
        statement[0] = '%()'
      got.code.push statement

    got.code.unshift '=>', [] if got.code.length

    got.data = @data

    got

  got_code_section: (got)->
    @code = got
    return

  got_comment_lines: (got)->
    return

  got_assignment_statement: (got)->
    [[variable, operator], expression] = got
    [operator, variable, expression]

  got_expression_statement: (got)->
    [left, right] = got

    pick = {}

    if right?
      right[1] = left
      statement = right
      _.merge(pick, statement[1].pick, statement[2].pick)
    else
      statement = left

    pick = _.keys pick
    if pick.length > 0
      statement = ['()', pick, statement]

    statement

  got_code_expression: (got)->
    [object, calls] = got
    expr = [object, calls...]

    pick = {}
    for e in expr
      _.merge pick, e.pick || {}

    if expr.length == 1
      expr = expr[0]
    else
      expr = ['.', expr...]

    if _.isArray expr
      expr.pick = pick

    expr

  got_point_object: (got)->
    object = ['*', got]
    object.pick = "*#{got}": true
    object

  got_number_object: (got)->
    Number got

  got_call_object: (got)->
    [name, args] = got
    args ||= []
    object = [name, args...]

    object.pick = {}
    for a in args
      _.merge object.pick, a.pick || {}

    object

  got_call_arguments: (got)->
    got = got[0]
    args = [got.shift()]
    more = got[0]
    for item in more
      continue unless item.length
      args.push item[0]
    args

  got_assertion_expression: (got)->
    [operator, expression] = got
    [operator, null, expression]

  got_block_definition: ([label, user, points])->
    point = {}
    for p in points
      [name, expr, value, extra] = p
      point[name] = @apply_filters(value, expr)

    @data ||= []

    @data.push
      label: label
      point: point

#------------------------------------------------------------------------------
  apply_filters: (value, expr)->
    value = value.replace /^#.*\n/gm, ''

    value = value.replace /^\\/gm, ''

    if value.match /\n/
      value = value.replace /\n*$/, '\n'

    return value unless expr

    if expr == '(<)'
      value = value.replace /^    /gm, ''
    else
      throw "Unsupported point filter: '#{expr}'"

    value
