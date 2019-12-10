require '../../testml/run'

module.exports = class TestML.Run.TAP extends TestML.Run
  @run: (file)->
    (new @).from_file(file).test()
    return

  constructor: (params={})->
    super(params)

    @count = 0

    {@output} = params

    if TestML.browser
      @tap_output = ''
      @out = (text)->
        @tap_output += text + "\n"
      @err = (text)->
        @tap_output += text + "\n"

    else
      @out = (text)->
        process.stdout.write String(text) + "\n"
      @err = (text)->
        process.stderr.write String(text) + "\n"

    return

  testml_begin: ->
    @checked = false
    @planned = false

  testml_end: ->
    @tap_done() unless @planned

    if TestML.browser and @tap_output
      @output.value = @tap_output

    return

  testml_eq: (got, want, label)->
    @check_plan()

    diff = (
      _.isString(want) and
      want.match(/\n/) and
        (not @getv('Diff')? or @getv('Diff')) and
        not process.env.TESTML_NO_DIFF? or
        @getp('DIFF')
    )

    @tap_is got, want, label, diff

  testml_like: (got, want, label)->
    @check_plan()
    @tap_like got, want, label

  testml_has: (got, want, label)->
    @check_plan()
    @tap_has got, want, label

  testml_list_has: (got, want, label)->
    @check_plan()
    @tap_list_has got, want, label

  check_plan: ->
    return if @checked
    @checked = true

    if plan = @vars.Plan
      @planned = true
      @tap_plan plan

  tap_plan: (plan)->
    @out "1..#{plan}"

  tap_pass: (label)->
    label = ' - ' + label if label
    @out "ok #{++@count}#{label}"

  tap_fail: (label)->
    label = ' - ' + label if label
    @out "not ok #{++@count}#{label}"

  tap_ok: (ok, label)->
    if ok
      @tap_pass label

    else
      @tap_fail label

  tap_is: (got, want, label, diff)->
    if got == want
      @tap_pass label

    else
      @tap_fail label
      if diff
        global.JsDiff = require 'diff' unless TestML.browser

        @tap_fail label

        @tap_diag JsDiff.createTwoFilesPatch(
          'want', 'got',
          want, got,
          '', '',
          context: 3
        )
      else
        @show '         got:', got, '    expected:', want, label

  tap_like: (got, want, label)->
    if got.match want
      @tap_pass label
    else
      @tap_fail label
      @show '                 ', got, "    doesn't match", want, label

  tap_has: (got, want, label)->
    if got.indexOf(want) != -1
      @tap_pass label
    else
      @tap_fail label
      @show '     this string:', got, " doesn't contain:", want, label

  tap_list_has: (got, want, label)->
    if (_.findIndex got, (str)-> str == want) != -1
      @tap_pass label
    else
      @tap_fail label
      json = JSON.stringify got, null, 2
      @show '      this array:', json, " doesn't contain:", want, label

  tap_note: (msg)->
    @out msg.replace /^/mg, '# '

  tap_diag: (msg)->
    @err msg.replace /^/mg, '# '

  tap_done: ->
    @out "1..#{@count}"

  show: (got_prefix, got, want_prefix, want, label)->
    if label
      @err "#   Failed test '#{label}'"

    else
      @err "#   Failed test"

    if _.isString got
      got = "'#{got}'"
    @tap_diag "#{got_prefix} #{got}"

    if _.isString want
      want = "'#{want}'"
    @tap_diag "#{want_prefix} #{want}"
