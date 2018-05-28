require '../../testml/run'
require '../../testml/tap'

module.exports = class TestML.Run.TAP extends TestML.Run
  @run: (file)->
    (new @).from_file(file).test()
    return

  constructor: (params={})->
    super(params)

    {@output} = params

    @tap = new TestML.TAP

    return

  testml_begin: ->

  testml_end: ->
    @tap.done_testing()

    if TestML.browser and @output
      @output.value = @tap.output

    return

  testml_eq: (got, want, label)->
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

  testml_like: (got, want, label)->
    @tap.like got, want, label

  testml_str_has: (got, want, label)->
    if got.indexOf(want) != -1
      @tap.pass label
    else
      @tap.fail label

  testml_list_has: (got, want, label)->
    if (_.findIndex got, (str)-> str == want) != -1
      @tap.pass label
    else
      @tap.fail label

# vim: ft=coffee sw=2:
