require '../../testml/run'
require '../../testml/tap'

module.exports = class TestML.Run.TAP extends TestML.Run
  @run: (file)->
    (new @).from_file(file).test()

  constructor: ->
    super(arguments...)

    @tap = new TestML.TAP

  test_begin: ->

  test_end: ->
    @tap.done_testing()

  test_eq: (got, want, label)->
    @tap.is_eq got, want, label
