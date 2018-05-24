# require '../../../../testml-compiler/lib/testml-compiler/prelude'

require '../testml'

lodash = require 'lodash'

module.exports =
class TestML.Run
  @vtable:
    '=='    : 'assert_eq'
    '~~'    : 'assert_has'
    '=~'    : 'assert_like'

    '%()'   : 'pick_loop'
    '.'     : 'exec_expr'

    "$''"   : 'get_str'
    '*'     : 'get_point'
    '='     : 'set_var'

  block: undefined

  file: undefined
  version: undefined
  code: undefined
  data: undefined

  bridge: undefined
  stdlib: undefined

  vars: {}

  #----------------------------------------------------------------------------
  constructor: (params={})->
    { @file,
      @bridge,
      @stdlib,
      testml={},
    } = params

    { testml,
      @code,
      @data
    } = testml

    @version = testml

    global._ = lodash if not TestML.browser
    return

  from_file: (@file)->
    fs = require 'fs'

    {testml, @code, @data} = JSON.parse if @file == '-' \
      then fs.readFileSync('/dev/stdin').toString() \
      else fs.readFileSync(@file).toString()

    @version = testml

    return @

  test: ->
    @initialize()

    @test_begin()

    @exec_func [], @code

    @test_end()

    return

  #----------------------------------------------------------------------------
  getp: (name)->
    return unless @block
    value = @block.point[name]
    value = @exec(value)[0] if _.isArray value
    value

  getv: (name)->
    return @vars[name]

  setv: (name, value)->
    @vars[name] = value
    return

  #----------------------------------------------------------------------------
  exec: (expr, context=[])->
    return [expr] if \
      not(_.isArray expr) or
      _.isArray(expr[0]) or
      _.isString(expr[0]) and expr[0].match /^(?:=>|\/|\?|\!)$/

    args = _.clone expr
    opcode = name = args.shift()
    if call = @constructor.vtable[opcode]
      return_ = @[call](args...)

    else
      args = _.map args, (x)=>
        if _.isArray x then @exec(x)[0] else x

      args.unshift (_.reverse context)...

      if name.match /^[a-z]/
        call = name.replace /-/g, '_'
        throw "Can't find bridge function: '#{name}'" \
          unless @bridge?[call]
        return_ = @bridge[call](args...)

      else if name.match /^[A-Z]/
        call = _.lowerCase name
        throw "Unknown TestML Standard Library function: '#{name}'" \
          unless @stdlib[call]
        return_ = @stdlib[call](args...)

      else
        throw "Can't resolve TestML function '#{name}'"

    return if return_ == undefined then [] else [return_]

  exec_func: (context, [signature, function_...])->
    for statement in function_
      @exec statement

    return

  exec_expr: (args...)->
    context = []

    for call in args
      context = @exec call, context

    return unless context.length
    return context[0]

  pick_loop: (list, expr)->
    for block in @data
      pick = true
      for point in list
        if (point.match(/^\*/) and ! block.point[point[1..]]?) or
           (point.match(/^\!\*/) and block.point[point[2..]]?)
          pick = false
          break

      if pick
        @block = block
        @exec expr

    @block = undefined

    return

  get_str: (string)->
    string = string.replace /\{([\-\w+])\}/g, (m, name)=>
      @vars[name] || ''

    string = string.replace /\{\*([\-\w+])\}/g, (m, name)=>
      @block.point[name] || ''

    return string

  get_point: (name)->
    return @getp name

  set_var: (name, expr)->
    @setv(name, @exec(expr)[0])
    return

  assert_eq: (left, right, label_expr)->
    got = @exec(left)[0]

    want = @exec(right)[0]

    label = @get_label(label_expr)

    # method = assertion["eq+#{@stdlib.type(got,want)}"]

    @test_eq got, want, label

    return

  #----------------------------------------------------------------------------
  initialize: ->
    @code.unshift []

    @data = _.map @data, (block)=>
      new TestML.Block block

    if not @bridge
      @bridge = new(require process.env.TESTML_BRIDGE)

    if not @stdlib
      @stdlib = new(require '../testml/stdlib')

    return

  get_label: (label_expr='')->
    label = @exec(label_expr)[0]

    if not label
      label = @getv('Label') || ''
      if label.match /\{\*?[\-\w]+\}/
        label = @exec(["$''", label])[0]

    block_label = if @block? then @block.label else ''

    if label
      label = label.replace /^\+/, block_label
      label = label.replace /\+$/, block_label
      label = label.replace /\{\+\}/, block_label
    else
      label = block_label

    return label

#------------------------------------------------------------------------------
TestML.Block = class
  constructor: ({@label, @point})->

# vim: set ft=coffee sw=2:
