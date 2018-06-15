require('pegex').require 'tree'

class TestMLCompiler.AST extends Pegex.Tree
  constructor: (args={})->
    super()
    @code = []
    @data = []
    @point = {}
    @transforms = {}
    {@file, @importer} = args

  final: ->
    got = testml: '0.3.0', code: [], data: []

    for statement in @code
      if _.isPlainObject statement
        if imports = statement.imports
          for ast in imports
            die "Can't import code after data started" \
              if ast.code.length and got.data.length
            got.code.push ast.code...
            got.data.push ast.data...
      else
        if statement[0] == '<>'
          statement[0] = '%<>'
        else if statement[0] == '=>'
          for s in statement[2]
            if s[0] == '<>'
              statement = ['%<>', [], statement]
              break
        else if statement[0] == '%' and _.keys(statement[1].pick).length
          statement = ['%<>', _.keys(statement[1].pick), statement]

        got.code.push statement

    got.data.push (@make_data @data)...

    got

  got_code_section: (got)->
    @code = got
    return

  got_import_directive: (got)->
    [[name, more]] = got
    names = [name]
    for name in more
      names.push name[0] if name[0]?
    imports = []
    for name in names
      imports.push @importer name, @file
    imports: imports

  got_assignment_statement: (got)->
    [[variable, operator], expression] = got
    [operator, variable, expression]

  got_loop_statement: (got)->
    expr = got[0]
    pick = expr.pick || {}
    ['%<>', _.keys(pick), expr]

  got_pick_statement: ([pick, statement])->
    ['<>', pick, statement]

  got_expression_statement: (got)->
    if _.isPlainObject got[0]
      label = got.shift()

    pick = {}

    [left, right, suffix_label] = got

    if not suffix_label and _.isPlainObject right
      suffix_label = right
      right = null

    if right?
      right[1] = left
      statement = right
      _.merge(pick, statement[1].pick, statement[2].pick)
    else
      statement = left

    if label?
      statement.push label.label
    else if suffix_label?
      statement.push suffix_label.label

    pick = _.keys pick
    if pick.length > 0
      statement = ['<>', pick, statement]

    statement

  got_expression_label: (got)->
    return label: got

  got_suffix_label: (got)->
    return label: got

  got_pick_expression: (got)->
    got = got[0]
    pick = "#{got.shift()}": true
    more = got[0]
    for item in more
      continue unless item.length
      pick[item[0]] = true
    _.keys pick

  got_code_expression: (got)->
    [object, calls, each] = got
    expr = [object, calls...]

    pick = {}
    for e in expr
      _.merge pick, e.pick || {}

    if expr.length == 1
      expr = expr[0]
      if object.callable
        expr = ['&', expr]
    else
      expr = ['.', expr...]

    if each?
      expr = ['%', expr, each]

    if _.isArray expr
      expr.pick = pick

    expr

  got_point_object: (got)->
    [name, indices] = got
    object = ['*', name]

    indices ||= []
    for [opcode, index] in indices
      object = [opcode, object, index]

    object.pick = "*#{name}": true

    object

  got_double_string: (got)->
    value = @decode got
    value = ["$''", value] if value.match /^(?:\\\\|[^\\])*?\{/
    value

  got_number_object: (got)->
    Number got

  got_regex_object: (got)->
    ['/', got]

  got_list_object: ([got])->
    list = []
    [first, rest] = got
    rest = _.filter _.map rest, (x)-> x[0]
    if first?
      list.push first
      for item in rest
        list.push item
    [list]

  got_function_object: (got)->
    signature = if got.length == 2 \
      then got.shift()[0] \
      else []

    got.unshift '=>', signature

    got.pick = {}
    for item in signature
      got.pick[item] = true if item.match /^\*/

    got

  got_callable_function_object: (got)->
    @got_function_object got

  got_function_variables: (got)->
    vars = [got.shift()]
    return [] unless got.length
    more = got[0]
    for item in more
      continue unless item.length
      vars.push item[0]
    vars

  got_call_object: (got)->
    [name, args, indices] = got
    if args?.indices
      indices = args
      args = null

    callable = args? and args.length == 0
    args ||= []
    indices ||= []
    object = [name, args...]

    for [opcode, index] in indices
      object = [opcode, object, index]

    object.pick = {}
    for a in args
      _.merge object.pick, a.pick || {}

    object.callable = callable

    object

  got_lookup_indices: (got)->
    indices = _.map got, (index)=>
      opcode = ':'
      index = switch
        when m = index.match /^"(.*)"$/ then ["$''", m[1]]
        when m = index.match /^'(.*)'$/ then m[1]
        when m = index.match /^\((.*)\)$/ then [m[1]]
        when m = index.match /^\[(.*)\]$/
          opcode = '[]'
          [m[1]]
        when m = index.match /^-?\d/
          opcode = '[]'
          Number index
        else index
      [opcode, index]

    indices.indices = true

    indices

  got_lookup_index: (got)->
    got[0]

  got_call_arguments: (got)->
    got = got[0]
    args = [got.shift()]
    return [] unless got.length
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
      [inherit, name, from, has_transforms, transforms, value] = p
      if name.match /^(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF)$/
        point[name] = true
      else
        point[name] =
          @make_point(name, value, inherit, from, has_transforms, transforms)

    @data ||= []

    block =
      label: label
      point: point

    block.user = user if user.match /\S/

    @data.push block

  got_point_single: (got)->
    value = got[5].replace /^\ +/, ''
    if value.match /^-?\d+(\.\d+)?$/
      value = Number value
    else if m = value.match /^'(.*)'\s*$/
      value = m[1]
    else if m = value.match /^"(.*)"\s*$/
      value = @decode m[1]

    got[5] = value

    got

  got_comment_lines: (got)->
    return

#------------------------------------------------------------------------------
  decoder:
    n: '\n'
    t: '\t'
    s: ' '
    '\\': '\\'

  decode: (str)->
    str.replace /\\(.)/g, (m, char)=>
      @decoder[char] || ''

  make_point: (name, value, inherit, from, has_transforms, transform_expr)->
    return value unless _.isString value

    throw "Can't use '--- #{name}=#{from}' without '^' in front" \
      if from and not inherit

    if inherit
      key = from || name
      value = @point[key] || ''

      if not has_transforms
        transform_expr = @transforms[key] || ''

    else
      @point[name] = value

    transforms = {}
    _.map _.split(transform_expr, ''), (f)-> transforms[f] = true

    @transforms[name] = transform_expr unless inherit

    if _.isString value
      if not transforms['#']
        value = value.replace /^#.*\n/gm, ''

      value = value.replace /^\\/gm, ''

      if not transforms['+'] and value.match /\n/
        value = value.replace /\n+$/, '\n'
        value = '' if value == '\n'

      if transforms['<']
        value = value.replace /^    /gm, ''

      if transforms['~']
        value = value.replace /\n+/g, '\n'

      if transforms['@']
        if value.match /\n/
          value = value.replace(/\n$/, '').split /\n/
        else
          value = value.split /\s+/
        value = [value]

      else if transforms['%']
        if TestMLCompiler.browser
          CoffeeScript = window.CoffeeScript
        else
          CoffeeScript = require('coffeescript')

        value = eval CoffeeScript.compile(value, bare: true)

        if _.isPlainObject(value) or _.isArray value
          value = [value]

      else if transforms['-']
        value = value.replace /\n$/, ''

    if transforms['"']
      if _.isArray(value) and _.isArray value[0]
        value[0] = _.map value[0], (str)=>
          if _.isString(str) then @decode(str) else str
      else
        value = @decode(value) if _.isString value

    if transforms['/']
      if _.isArray(value) and _.isArray value[0]
        value = _.map value[0], (regex)-> ['/', regex]
        value = [value]
      else
        flag = if value.match /\n/ then 'x' else ''
        value = ['/', value.replace(/\n$/, '')]
        value.push flag if flag

    if inherit and from
      @point[name] = value

    value

  make_data: (data)->
    blocks = []

    for block in data
      if block.point.SKIP
        continue
      if block.point.ONLY
        return [block]
      if block.point.HEAD
        blocks = []
      if block.point.LAST
        blocks.push block
        return blocks

      blocks.push block

    return blocks

# vim: ft=coffee sw=2:
