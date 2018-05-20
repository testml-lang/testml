require '../../testml/run'
require '../../testml/tap'

module.exports = class TestML.Run.TAP extends TestML.Run
  @run: (file)->
    (new @).from_file(file).test()
    return

  constructor: (params={})->
    super(params)
    @tap = new TestML.TAP
    return

  test_begin: ->

  test_end: ->
    @tap.done_testing()
    return

  test_eq: (got, want, label)->
    if _.isString(want) and
      got != want and
      want.match(/\n/) and (
        @getv('Diff') or
        @getp('DIFF')
      )
      global.JsDiff = require 'diff' unless TestML.browser

      @tap.fail label

      @tap.diag JsDiff.createTwoFilesPatch(
        'want', 'got',
        want, got,
        '', '',
        context: 3
      )

    else
      @tap.is_eq got, want, label

    return

# vim: ft=coffee sw=2:
