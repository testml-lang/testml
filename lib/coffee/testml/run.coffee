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

    '.'  : 'exec_expr'
    '%'  : 'for_each'
    '%()': 'pick_loop'
    '()' : 'pick_exec'
    '=>' : 'exec_func'

    '&'  : 'call_func'
    "$''": 'get_str'
    ':'  : 'get_hash'
    '[]' : 'get_list'
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

  warned_only: false
  error: null

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
    @testml_begin()

    for statement in @code
      @exec statement

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
    return [expr] unless @get_type(expr) == 'expr'

    args = _.clone expr

    opcode = name = args.shift()
    if call = @constructor.vtable[opcode]
      call = call[0] if _.isArray call
      # Might need to pass context to => calls here.
      return_ = @[call](args...)

    else
      args.unshift (_.reverse context)...

      if (value = @vars[name])?
        if args.length
          return_ = @exec value, args...
        else
          return_ = value

      else if name.match /^[a-z]/
        return_ = @call_bridge name, args

      else if name.match /^[A-Z]/
        return_ = @call_stdlib name, args

      else
        throw "Can't resolve TestML function '#{name}'"

    return if return_ == undefined then [] else [return_]

  exec_expr: (calls...)->
    context = []

    @error = null
    for call in calls
      if ! @error
        try
          context = @exec call, context
        catch e
          @error = @call_stdlib  'Error', "#{e}"
      else
        if call[0] == 'Catch'
          context = [@error]
          @error = null

    throw @error[1] if @error

    return unless context.length
    return context[0]

  for_each: (list, expr)->
    list = @exec(list)[0]

    for item in list[0]
      @vars._ = [item]
      @exec expr[0]

  pick_loop: (list, expr)->
    for block in @data
      @block = block

      if block.point.ONLY and ! @warned_only
        @warn "Warning: TestML 'ONLY' in use."
        @warned_only = true

      @exec ['()', list, expr]

    @block = undefined

    return

  pick_exec: (list, expr)->
    pick = true
    for point in list
      if (point.match(/^\*/) and ! @block.point[point[1..]]?) or
          (point.match(/^\!\*/) and @block.point[point[2..]]?)
        pick = false
        break

    if pick
      if @get_type(expr) == 'func'
        @exec_func expr[1..]...
      else
        @exec expr

  exec_func: (signature, statements)->
    for statement in statements
      @exec statement

  call_func: (name)->
    func = @vars[name]
    throw "Tried to call '#{name}' but is not a function" \
      unless func? and @get_type(func) == 'func'
    @exec_func func[1..]...

  get_str: (string)->
    return @interpolate string

  get_hash: (hash, key)->
    hash = (@exec(hash))[0]
    return @cook hash[0][key]

  get_list: (list, index)->
    list = @exec(list)[0]
    return @cook list[0][index]

  get_point: (name)->
    return @getp name

  set_var: (name, expr)->
    if @get_type expr == 'func'
      @setv name, expr
    else
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
  call_stdlib: (name, args)->
    @stdlib ||= new(require '../testml/stdlib') @

    call = _.lowerCase name
    throw "Unknown TestML Standard Library function: '#{name}'" \
      unless @stdlib[call]

    args = _.map args, (x)=> @uncook @exec(x)[0]

    @cook @stdlib[call](args...)

  call_bridge: (name, args)->
    @bridge ||= new(require process.env.TESTML_BRIDGE)

    call = name.replace /-/g, '_'
    throw "Can't find bridge function: '#{name}'" \
      unless @bridge[call]

    args = _.map args, (x)=> @uncook @exec(x)[0]

    return_ = @bridge[call](args...)

    return unless return_?

    @cook return_

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

  get_type: (value)->
    throw "Can't get type of undefined value" \
      if typeof value == 'undefined'

    return 'null' if value == null

    types =
      string: 'str'
      number: 'num'
      boolean: 'bool'
      testml:
        '=>': 'func'
        '/': 'regex'
        '!': 'error'
        '?': 'native'
      group:
        Object: 'hash'
        Array: 'list'

    type = types[typeof value] ||
      types[name = value.constructor.name] ||
        if name == 'Array'
          if value.length == 0
            'none'
          else
            if typeof value[0] == 'string'
              types.testml[value[0]] || 'expr'
            else
              types.group[value[0].constructor.name] || 'native'
        else
          throw "Bad TestML internal value: '#{name}'"

    return type \
      or throw "Can't get type of #{require('util').inspect value}"

  cook: (value)->
    return [] if value == undefined
    return null if value == null
    name = value.constructor.name
    return value if name.match /^(?:String|Number|Boolean)$/
    return [value] if name.match /^(?:Array|Object)$/

    return ['/', value] if name == 'RegExp'
    return ['!', value] if name == 'TestMLError'
    return value['func'] if name == 'TestMLFunction'
    return ['?', value]

  uncook: (value)->
    type = @get_type value

    switch
      when type.match /^(?:str|num|bool|null)$/ then value
      when type.match /^(?:list|hash)$/ then value[0]
      when type.match /^(?:error|native)$/ then value[1]
      when type == 'func'
        new TestMLFunction value
      when type == 'regex'
        if typeof value[1] == 'string'
          new RegExp value[1]
        else value[1]
      when type == 'none' then undefined
      else XXX value

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
    transform = (value)=>
      if label
        switch
          when @get_type(value).match /^(?:list|hash)$/ then \
            JSON.stringify(value[0]).replace /"/g, ''
          else String(value).replace /\n/g, '␤'
      else
        switch
          when @get_type(value).match /^(?:list|hash)$/ then \
            JSON.stringify(value[0]).replace /"/g, ''
          else String(value)

    transform1 = (m, name)=>
      return '' unless (value = @vars[name])?
      transform value

    transform2 = (m, name)=>
      return '' unless (value = @block?.point[name])?
      transform value

    string = string.replace /\{([\-\w]+)\}/g, transform1

    string = string.replace /\{\*([\-\w]+)\}/g, transform2

    return string

  #----------------------------------------------------------------------------
  test_types: ->
    class Bad

    console.log "null   - #{@get_type null}"
    console.log "none   - #{@get_type []}"

    console.log "str    - #{@get_type ""}"
    console.log "num    - #{@get_type 1}"
    console.log "bool   - #{@get_type false}"

    console.log "list   - #{@get_type [[]]}"
    console.log "hash   - #{@get_type [{}]}"

    console.log "regex  - #{@get_type ['/','']}"
    console.log "func   - #{@get_type ['=>','']}"
    console.log "error  - #{@get_type ['!','']}"
    console.log "native - #{@get_type ['?','']}"
    console.log "expr   - #{@get_type ['foo']}"

    console.log "new Bad   - #{try @get_type new Bad catch e then e}"
    console.log "new Regex - #{try @get_type /x/ catch e then e}"
    console.log "undefined - #{try @get_type() catch e then e}"

    throw "Tested TestML internal types"

# (new TestML.Run).test_types()

#------------------------------------------------------------------------------
TestML.Block = class
  constructor: ({@label, @point, @user=''})->

TestMLFunction = class
  constructor: (@func)->

