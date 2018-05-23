# require '../../../../testml-compiler/lib/testml-compiler/prelude'

require '../testml'

lodash = require 'lodash'

operator =
  '=='    : 'eq'
  '.'     : 'call'
  '=>'    : 'func'
  "$''"   : 'get-string'
  '[]'    : 'list'
  '%()'   : 'pickloop'
  '*'     : 'point'
  '/'     : 'regex'
  '='     : 'set-var'

module.exports =
class TestML.Run
  constructor: (params={})->
    {@file, testml={}, @bridge, @stdlib} = params
    {testml, @code, @data} = testml
    @version = testml
    @vars = {}

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

    @exec @code

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
    return [expr] unless _.isArray expr

    args = _.clone expr
    name = call = args.shift()
    if opname = operator[call]
      call = "exec_#{opname}".replace /-/g, '_'
      return_ = @[call](args...)

    else
      args = _.map args, (x)=>
        if _.isArray x then @exec(x)[0] else x

      args.unshift (_.reverse context)...

      if call.match /^[a-z]/
        call = call.replace /-/g, '_'
        throw "Can't find bridge function: '#{name}'" \
          unless @bridge?[call]
        return_ = @bridge[call](args...)

      else if call.match /^[A-Z]/
        call = _.lowerCase call
        throw "Unknown TestML Standard Library function: '#{name}'" \
          unless @stdlib[call]
        return_ = @stdlib[call](args...)

      else
        throw "Can't resolve TestML function '#{name}'"

    return if return_ == undefined then [] else [return_]

  exec_call: (args...)->
    context = []

    for call in args
      context = @exec call, context

    return unless context.length
    return context[0]

  exec_eq: (left, right, label_expr)->
    got = @exec(left)[0]

    want = @exec(right)[0]

    label = @get_label(label_expr)

    @test_eq got, want, label

    return

  exec_func: (signature, statements...)->
    for statement in statements
      @exec statement

    return

  exec_get_string: (string)->
    string = string.replace /\{([\-\w+])\}/g, (m, name)=>
      @vars[name] || ''

    string = string.replace /\{\*([\-\w+])\}/g, (m, name)=>
      @block.point[name] || ''

    return string

  exec_list: (expr...)->
    expr

  exec_pickloop: (list, expr)->
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

  exec_point: (name)->
    return @getp name

  exec_regex: (regex)->
    new RegExp regex

  exec_set_var: (name, expr)->
    @setv(name, @exec(expr)[0])
    return

  #----------------------------------------------------------------------------
  initialize: ->
    @code.unshift '=>', []

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
