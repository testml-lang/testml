class TestML.TAP
  constructor: ->
    @count = 0

    if TestML.browser
      @output = ''
      @out = (text)->
        @output += text + "\n"
      @err = (text)->
        @output += text + "\n"

    else
      @out = (text)->
        process.stdout.write String(text) + "\n"
      @err = (text)->
        process.stderr.write String(text) + "\n"

  pass: (label)->
    @out "ok #{++@count} - #{label}"

  fail: (label)->
    @out "not ok #{++@count} - #{label}"

  ok: (ok, label)->
    if ok
      @pass label

    else
      @fail label

  is_eq: (got, want, label, diff)->
    if got == want
      @pass label

    else
      @fail label
      if diff
        global.JsDiff = require 'diff' unless TestML.browser

        @fail label

        @diag JsDiff.createTwoFilesPatch(
          'want', 'got',
          want, got,
          '', '',
          context: 3
        )
      else
        @show '         got:', got, '    expected:', want, label

  like: (got, want, label)->
    if got.match new RegExp want
      @pass label
    else
      @fail label
      @show '                 ', got, "    doesn't match", want, label

  has: (got, want, label)->
    if got.indexOf(want) != -1
      @pass label
    else
      @fail label
      @show '     this string:', got, " doesn't contain:", want, label

  list_has: (got, want, label)->
    if (_.findIndex got, (str)-> str == want) != -1
      @pass label
    else
      @fail label
      json = JSON.stringify got, null, 2
      @show '      this array:', json, " doesn't contain:", want, label

  diag: (msg)->
    @err msg.replace /^/mg, '# '

  done_testing: ->
    @out "1..#{@count}"

  show: (got_prefix, got, want_prefix, want, label)->
    if label
      @err "#   Failed test '#{label}'"

    else
      @err "#   Failed test"

    if _.isString got
      got = "'#{got}'"
    @diag "#{got_prefix} #{got}"

    if _.isString want
      want = "'#{want}'"
    @diag "#{want_prefix} #{want}"

# vim: ft=coffee sw=2:
