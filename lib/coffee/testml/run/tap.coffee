require '../../testml/run'

module.exports = Run = class extends TestML.Run
  @run: (file)->
    (new Run file).test()

  constructor: ->
    super(arguments...)

    @tap = new require 'tap'

  test_begin: ->

  test_end: ->
    @tap.done()

  test_eq: (got, want, label)->
    @tap.equal got, want, label
