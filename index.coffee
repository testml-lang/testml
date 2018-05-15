show_error = (error)->
  console.log error
  if TestML.state.view == 'mocha'
    error = String error
    error = error.replace /\n/g, '<br>'
    error = error.replace /\ /g, '&nbsp;'
    $('#mocha').html('<span class="error">' + error + '</span>')

  else
    $('#output').val String error

  throw error

runTestML = (importer)->
  output = $('#output')
  output.val ''

  try
    compiler = new TestMLCompiler.Compiler importer: yamlImporter
    json = compiler.compile $('#testml').val()
    testml = JSON.parse json

  catch e
    show_error e

  if TestML.state.view == 'compiler'
    output.val json
    return

  try
    require = ->
    module = exports: {}
    eval CoffeeScript.compile $('#bridge').val(), bare: true
    bridge = new TestMLBridge

  catch e
    show_error e

  try
    if TestML.state.view == 'tap'
      runner = new TestML.Run.TAP
        testml: testml
        bridge: bridge
        stdlib: new TestML.StdLib
        output: output[0]
    else
      runner = new TestML.Run.Mocha
        testml: testml
        bridge: bridge
        stdlib: new TestML.StdLib

    runner.test()

  catch e
    show_error e


yamlImporter = (name)->
  result = null

  $.ajax
    url: './yaml/' + name + '.tml'
    success: (input)->
      compiler = new TestMLCompiler.Compiler importer: yamlImporter
      result = JSON.parse compiler.compile input
    async: false

  return result

setExample = (name)->
  name = @value unless _.isString name
  TestML.state.name = name
  TestML.state.type = 'example'

  TestML.params.set 'type', 'example'
  TestML.params.set 'name', name
  window.history.replaceState '', '', "?#{TestML.params.toString()}"
  $('#yaml')[0].selectedIndex = 0
  $('#test')[0].selectedIndex = 0
  $('#ctest')[0].selectedIndex = 0

  $('#testml').val window.examples["#{name}_testml"]
  $('#bridge').val window.examples["#{name}_bridge"]

  focusTop 'testml'
  runTestML()

setTestMLTest = (name)->
  name = @value unless _.isString name
  TestML.state.name = name
  TestML.state.type = 'test'

  TestML.params.set 'type', 'test'
  TestML.params.set 'name', name
  window.history.replaceState '', '', "?#{TestML.params.toString()}"
  $('#example')[0].selectedIndex = 0
  $('#yaml')[0].selectedIndex = 0
  $('#ctest')[0].selectedIndex = 0

  test_bridge = ''
  $.ajax
    url: './test/testml-bridge.coffee'
    success: (text)->
      test_bridge = text
    async: false

  $.get "test/" + name + ".tml", (text)->
    $('#bridge').val test_bridge
    $('#testml').val text
    focusTop 'testml'
    runTestML()

setCompilerTest = (name)->
  name = @value unless _.isString name
  TestML.state.name = name
  TestML.state.type = 'ctest'

  TestML.params.set 'type', 'ctest'
  TestML.params.set 'name', name
  window.history.replaceState '', '', "?#{TestML.params.toString()}"
  $('#example')[0].selectedIndex = 0
  $('#yaml')[0].selectedIndex = 0
  $('#test')[0].selectedIndex = 0

  test_bridge = ''
  $.ajax
    url: './ctest/testml-bridge.coffee'
    success: (text)->
      test_bridge = text
    async: false

  $.get "ctest/" + name + ".tml", (text)->
    $('#bridge').val test_bridge
    $('#testml').val text
    focusTop 'testml'
    runTestML()

setYAMLTest = (name)->
  name = @value unless _.isString name
  TestML.state.name = name
  TestML.state.type = 'yaml'

  TestML.params.set 'type', 'yaml'
  TestML.params.set 'name', name
  window.history.replaceState '', '', "?#{TestML.params.toString()}"
  $('#example')[0].selectedIndex = 0
  $('#test')[0].selectedIndex = 0
  $('#ctest')[0].selectedIndex = 0

  $.get "yaml/" + name + ".tml", (text)->
    $('#bridge').val yaml_bridge
    $('#testml').val """\
      Diff = True

      *in-yaml.load-yaml.to-json == *in-json
      *in-yaml.load-yaml.to-json == *in-json.load-json.to-json

      #{text}
      """
    focusTop 'testml'
    runTestML()

focusTop = (id)->
  setTimeout ->
    $('#' + id).scrollTop 0
    $('#' + id)[0].setSelectionRange 0, 0
  , 200

setView = ->
  if TestML.state.view == 'mocha'
    $('#output').hide()
    $('#mocha').show()
  else
    $('#mocha').hide()
    $('#output').show()

changeView = ->
  TestML.state.view = $('input[name=view]:checked').val()
  TestML.params.set 'view', TestML.state.view
  window.history.replaceState '', '', "?#{TestML.params.toString()}"

  setView()

  runTestML()

#------------------------------------------------------------------------------
math_testml = '''\
#!/usr/bin/env testml

"+ - {*a} + {*a} == {*c}":
  *a.add(*a) == *c

"+ - {*c} - {*a} == {*a}":
  *c.sub(*a) == *a

"+ - {*a} * 2 == {*c}":
  *a.mul(2) == *c

"+ - {*c} / 2 == {*a}":
  *c.div(2) == *a

"+ - {*a} * {*b} == {*d}":
  mul(*a, *b) == *d

=== Test Block 1
--- a: 3
--- c: 6

=== Test Block 2
--- a: -5
--- b: 7
--- c: -10
--- d: -35

'''

math_bridge = '''\
class TestMLBridge extends TestML.Bridge
  add: (x, y)->
    x + y

  sub: (x, y)->
    x - y

  mul: (x, y)->
    x * y

  div: (x, y)->
    x / y
'''

import_testml = '''\
Diff = True

"YAML Load == JSON      -- +":
  *in-yaml.load-yaml.to-json == *in-json

"YAML Load == JSON Load -- +":
*in-yaml.load-yaml.to-json == *in-json.load-json.to-json

%Import 229Q 27NA 2AUY 2EBW 2LFX
%Import 36F6 3ALJ 3GZX 3MYT 3R3P 3UYS
%Import 4CQQ 4GC6 4Q9F 4QFQ 4UYU 4V8U 4ZYM
%Import 52DL 54T7 57H4 5BVJ 5C5M 5GBF 5KJE 5NYZ 5WE3

'''

import_bridge = yaml_bridge = '''\
class TestMLBridge extends TestML.Bridge
  load_yaml: (yaml)->
    yaml = yaml.replace /<SPC>/g, ' '
    yaml = yaml.replace /<TAB>/g, '\\t'
    jsyaml.load yaml

  load_json: (json)->
    JSON.parse json

  to_json: (node)->
    JSON.stringify(node, null, 2) + '\\n'
'''

window.examples =
  math_testml: math_testml
  math_bridge: math_bridge
  import_testml: import_testml
  import_bridge: import_bridge

#------------------------------------------------------------------------------
$ ->
  state = TestML.state = {}
  TestML.params = new URLSearchParams window.location.search[1..]
  state.type = TestML.params.get('type') || 'example'
  state.name = TestML.params.get('name') || 'math'
  state.view = TestML.params.get('view') || 'tap'
  TestML.params.set('type', state.type)
  TestML.params.set('name', state.name)
  TestML.params.set('view', state.view)

  setView()

  setTimeout ->
    $("##{state.type}")[0].value = state.name
    $("input[name=view][value=" + state.view + "]").prop 'checked', true
  , 50

  if state.type == 'example'
    setExample state.name
  else if state.type == 'test'
    setTestMLTest state.name
  else if state.type == 'ctest'
    setCompilerTest state.name
  else if state.type == 'yaml'
    setYAMLTest state.name

  $('#example').change setExample
  $('#test').change setTestMLTest
  $('#ctest').change setCompilerTest
  $('#yaml').change setYAMLTest
  $('input[name=view]').change changeView

  $('#testml').on 'keyup', _.debounce runTestML, 333
  $('#bridge').on 'keyup', _.debounce runTestML, 333

  $.get "./test/list", (text)->
    testml_tests = _.split text, '\n'
    testml_tests.pop()
    select = $('#test')
    for name in testml_tests
      $('<option />', value: name, text: name).appendTo select

  $.get "./ctest/list", (text)->
    testml_tests = _.split text, '\n'
    testml_tests.pop()
    select = $('#ctest')
    for name in testml_tests
      $('<option />', value: name, text: name).appendTo select

  $.get "./yaml/list", (text)->
    yaml_tests = _.split text, '\n'
    yaml_tests.pop()
    select = $('#yaml')
    for name in yaml_tests
      $('<option />', value: name, text: name).appendTo select

# vim: ft=coffee sw=2:
