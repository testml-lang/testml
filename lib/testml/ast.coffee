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
      if statement[0].match /^(?:=>|==|=~|~~)$/
        statement = @add_loop statement
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

    if right?
      right[1] = left
      statement = right
      statement.points = {}
      _.merge(statement.points, statement[1].points, statement[2].points)
    else
      statement = left

    statement

  got_code_expression: (got)->
    [object, calls] = got
    expr = [object, calls...]

    points = {}
    for e in expr
      _.merge points, e.points || {}

    if expr.length == 1
      expr = expr[0]
    else
      expr = ['.', expr...]

    if _.isArray expr
      expr.points = points

    expr

  got_point_object: (got)->
    object = ['*', got]
    object.points = "#{got}": true
    object

  got_number_object: (got)->
    Number got

  got_call_object: (got)->
    [name, args] = got
    args ||= []
    object = [name, args...]

    object.points = {}
    for a in args
      _.merge object.points, a.points || {}

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
  add_loop: (statement)->
    points = _.keys(statement.points || {})
    points = _.map points, (p)-> "*#{p}"

    if points.length
      statement = ['%()', points, statement]

    statement

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
