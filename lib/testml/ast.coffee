module.paths = TestML.module_paths

require('pegex').require 'tree'

(global.TestML ||= {}).AST = class extends Pegex.Tree
  constructor: ->
    super()
    @code = []
    @data = []

  final: ->
    testml: '0.3.0'
    code: @code
    data: @data

  got_code_section: (got)->
    func = ['=>', []]
    func.push got...
    @code = func

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

  got_call_object: (got)->
    got

  got_assertion_expression: (got)->
    [operator, expression] = got
    [operator, null, expression]

  got_block_definition: ([label, user, points])->
    point = {}
    for p in points
      [name, expr, value, extra] = p
      point[name] = value

    @data.push
      label: label
      point: point
