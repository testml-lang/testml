require('pegex').require 'tree'

class TestML.AST extends Pegex.Tree
  constructor: ->
    super()
    @code = null
    @data = null

  final: ->
    got =
      testml: '0.3.0'

    got.code = @code if @code
    got.data = @data if @data

    got

  got_code_section: (got)->
    if got.length
      @code = ['=>', [], got...]
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
      right
    else
      left

  got_code_expression: (got)->
    [object, calls] = got
    expr = [ object, calls... ]
    if expr.length == 1
      expr[0]
    else
      ['.', expr...]

  got_point_object: (got)->
    ['*', got]

  got_number_object: (got)->
    Number got

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
