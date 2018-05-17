# require '../../../../testml-compiler/lib/testml-compiler/prelude'

require '../testml'

lodash = require 'lodash'

operator =
  '=='    : 'eq'
  '.'     : 'call'
  '=>'    : 'func'
  "$''"   : 'get-string'
  '%()'   : 'pickloop'
  '*'     : 'point'

module.exports = class TestML.Run
  constructor: (@testml, @bridge)->
    global._ = lodash if not TestML.browser

  from_file: (@testml_file)->
    @testml = JSON.parse @read_file @testml_file

    return @

  test: ->
    @initialize()

    @test_begin()

    @exec @code

    @test_end()

  initialize: ->
    @code = @testml.code

    @code.unshift '=>', []

    @data = _.map @testml.data, (block)=>
      new TestML.Block block

    if not @bridge
      module.paths.unshift process.env.TESTML_INPUT_DIR

      @bridge = new(require process.env.TESTML_BRIDGE)

  exec: (expr, context=[])->
    return [expr] unless _.isArray expr

    args = _.clone expr
    call = args.shift()
    if name = operator[call]
      call = "exec_#{name}".replace /-/g, '_'
      return_ = @[call](args...)
    else
      args = _.map args, (x)=>
        if _.isArray x then @exec(x)[0] else x

      args.unshift (_.reverse context)...

      if call.match /^[a-z]/
        call = call.replace /-/g, '_'
        throw "Can't find bridge function: '#{call}'" \
          unless @bridge[call]
        return_ = @bridge[call](args...)

      else if call.match /^[A-Z]/
        call = _.lowerCase call
        throw "Unknown TestML Standard Library function: '#{call}'" \
          unless @stdlib.can($call)
        return_ = @stdlib[call](args...)

      else
        throw "Can't resolve TestML function '#{call}'"

    return if return_ == undefined then [] else [return_]

  exec_call: (args...)->
    context = []

    for call in args
      context = @exec call, context

    if context.length
      return context[0]

    return

  exec_eq: (left, right, label)->
    got = @exec(left)[0]

    want = @exec(right)[0]

    label = @get_label(label)

    @test_eq got, want, label

  exec_func: (signature, statements...)->
    for statement in statements
      @exec statement

  exec_get_string: (string)->
    string = string.replace /\{([\-\w+])\}/g, (m, name)=>
      @vars[name] || ''

    string = string.replace /\{\*([\-\w+])\}/g, (m, name)=>
      @block.point[name] || ''

  exec_pickloop: (list, expr)->
    for block in @data
      pick = true
      for point in list
        if point.match /^\*/
          if ! block.point[point[1..]]?
            pick = false
            break

        else if point.match /^\!\*/
          if block.point[point[2..]]?
            pick = false
            break

      if pick
        @block = block
        @exec expr

    @block = undefined

  exec_point: (name)->
    @block.point[name]

  #----------------------------------------------------------------------------
  read_file: (file_path)->
    fs = require 'fs'

    if file_path == '-'
      fs.readFileSync('/dev/stdin').toString()
    else
      fs.readFileSync(file_path).toString()

  get_label: (label_expr='')->
    label = @exec(label_expr)[0]

    block_label = @block.label

    if label
      label = label.replace /^\+/, block_label
      label = label.replace /\+$/, block_label
      label = label.replace /\{\+\}/, block_label
    else
      label = block_label

    label

TestML.Block = class
  constructor: ({@label, @point})->
