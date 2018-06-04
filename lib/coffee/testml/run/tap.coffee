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
    @checked = false
    @planned = false

  testml_end: ->
    @tap.done_testing() unless @planned

    if TestML.browser and @output
      @output.value = @tap.output

    return

  testml_eq: (got, want, label)->
    @check_plan()

    diff = (
      _.isString(want) and
      want.match(/\n/) and (
        @getv('Diff') or
        @getp('DIFF')
      )
    )

    @tap.is_eq got, want, label, diff

  testml_like: (got, want, label)->
    @check_plan()
    @tap.like got, want, label

  testml_has: (got, want, label)->
    @check_plan()
    @tap.has got, want, label

  testml_list_has: (got, want, label)->
    @check_plan()
    @tap.list_has got, want, label

  out: (msg)->
    @tap.note(msg)

  err: (msg)->
    @tap.diag(msg)

  check_plan: ->
    return if @checked
    @checked = true

    if plan = @vars.Plan
      @planned = true
      @tap.plan plan
