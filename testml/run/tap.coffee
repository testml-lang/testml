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
    diff = (
      _.isString(want) and
      want.match(/\n/) and (
        @getv('Diff') or
        @getp('DIFF')
      )
    )

    @tap.is_eq got, want, label, diff

  testml_like: (got, want, label)->
    @tap.like got, want, label

  testml_has: (got, want, label)->
    @tap.has got, want, label

  testml_list_has: (got, want, label)->
    @tap.list_has got, want, label

  warn: (msg)->
    @tap.diag(msg)

# vim: ft=coffee sw=2:
