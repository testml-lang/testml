require '../testml'
require 'ingy-prelude' if TestML.env['TESTML_DEVEL']
lodash = require 'lodash'

module.exports =
class TestML.Run
  @vtable:
    '==': [
      'assert_eq',
      'assert_%1_eq_%2',
        'str,str': ''
        'num,num': ''
        'bool,bool': ''
    ]

    '~~': [
      'assert_has',
      'assert_%1_has_%2',
        'str,str': ''
        'str,list': ''
        'list,str': ''
        'list,list': ''
    ]

    '=~': [
      'assert_like',
      'assert_%1_like_%2',
        'str,regex': ''
        'str,list': ''
        'list,regex': ''
        'list,list': ''
    ]

    '%()': 'pick_loop'
    '.'  : 'exec_expr'

    "$''": 'get_str'
    '*'  : 'get_point'
    '='  : 'set_var'

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

    @testml_begin()

    @exec_func [], @code

    @testml_end()

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
      _.isPlainObject(expr[0]) or
      _.isString(expr[0]) and expr[0].match /^(?:=>|\/|\?|\!)$/

    args = _.clone expr
    opcode = name = args.shift()
    if call = @constructor.vtable[opcode]
      call = call[0] if _.isArray call
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
      if block.point.ONLY and ! @warned_only
        @warn "Warning: TestML 'ONLY' in use."
        @warned_only = true

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
    return @interpolate string

  get_point: (name)->
    return @getp name

  set_var: (name, expr)->
    @setv(name, @exec(expr)[0])
    return


  assert_eq: (left, right, label)->
    @vars.Got = got = @exec(left)[0]
    @vars.Want = want = @exec(right)[0]
    method = @get_method('==', got, want)
    @[method] got, want, label
    return

  assert_str_eq_str: (got, want, label)->
    @testml_eq(got, want, @get_label label)

  assert_num_eq_num: (got, want, label)->
    @testml_eq(got, want, @get_label label)

  assert_bool_eq_bool: (got, want, label)->
    @testml_eq(got, want, @get_label label)


  assert_has: (left, right, label)->
    got = @exec(left)[0]
    want = @exec(right)[0]
    method = @get_method('~~', got, want)
    @[method] got, want, label
    return

  assert_str_has_str: (got, want, label)->
    @vars.Got = got
    @vars.Want = want
    @testml_has(got, want, @get_label label)

  assert_str_has_list: (got, want, label)->
    for str in want[0]
      @assert_str_has_str(got, str, label)

  assert_list_has_str: (got, want, label)->
    @vars.Got = got
    @vars.Want = want
    @testml_list_has(got[0], want, @get_label label)

  assert_list_has_list: (got, want, label)->
    for str in want[0]
      @assert_list_has_str(got, str, label)


  assert_like: (left, right, label)->
    got = @exec(left)[0]
    want = @exec(right)[0]
    method = @get_method('=~', got, want)
    @[method] got, want, label
    return

  assert_str_like_regex: (got, want, label)->
    @vars.Got = got
    @vars.Want = "/#{want[1]}/"
    @testml_like(got, want[1], @get_label label)

  assert_str_like_list: (got, want, label)->
    for regex in want[0]
      @assert_str_like_regex got, regex, label

  assert_list_like_regex: (got, want, label)->
    for str in got[0]
      @assert_str_like_regex str, want, label

  assert_list_like_list: (got, want, label)->
    for str in got[0]
      for regex in want[0]
        @assert_str_like_regex str, regex, label

  #----------------------------------------------------------------------------
  initialize: ->
    @code.unshift []

    @data = _.map @data, (block)=>
      new TestML.Block block

    if not @bridge
      @bridge = new(require process.env.TESTML_BRIDGE)

    if not @stdlib
      @stdlib = new(require '../testml/stdlib') @

    return

  get_method: (key, args...)->
    sig = []
    for arg in args
      sig.push @get_type arg
    sig_str = sig.join ','

    entry = @constructor.vtable[key]
    [name, pattern, vtable] = entry
    method = vtable[sig_str] || pattern.replace /%(\d+)/g, (m, num)->
      sig[num - 1]
    throw "Can't resolve #{name}(#{sig_str})" unless method

    throw "Method '#{method}' does not exist" unless @[method]

    return method

  get_type: (object)->
    type = switch
      when object == null then 'null'
      when typeof object == 'string' then 'str'
      when typeof object == 'number' then 'num'
      when typeof object == 'boolean' then 'bool'
      when object instanceof Array then switch
        when object[0] instanceof Array then 'list'
        when _.isPlainObject object[0] then 'hash'
        when object[0] == '/' then 'regex'
        else null
      else null

    throw "Can't get type of #{require('util').inspect object}" unless type

    type

  get_label: (label_expr='')->
    label = @exec(label_expr)[0]

    label ||= @getv('Label') || ''
    block_label = if @block? then @block.label else ''

    if label
      label = label.replace /^\+/, block_label
      label = label.replace /\+$/, block_label
      label = label.replace /\{\+\}/, block_label
    else
      label = block_label

    return @interpolate label, true

  interpolate: (string, label=false)->
    transform = (m, name)=>
      if label
        return '' unless v = @vars[name]
        switch
          when @get_type(v) == 'list' then \
            JSON.stringify(v[0]).replace /"/g, ''
          else String(v).replace /\n/g, '␤'
      else
        return '' unless v = @block.point[name]
        switch
          when @get_type(v) == 'list' then \
            JSON.stringify(v[0]).replace /"/g, ''
          else String(v)

    string = string.replace /\{([\-\w]+)\}/g, transform

    string = string.replace /\{\*([\-\w]+)\}/g, transform

    return string
#------------------------------------------------------------------------------

TestML.Block = class
  constructor: ({@label, @point})->

# vim: set ft=coffee sw=2:
