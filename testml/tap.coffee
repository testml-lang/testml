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

  is_eq: (got, want, label)->
    if got == want
      @pass label

    else
      @fail label

      if label
        @err "#   Failed test '#{label}'"

      else
        @err "#   Failed test"

      if _.isString got
        got = got.replace /^/mg, '# '
        got = got.replace /^\#\ /, ''
        got = got.replace /\n$/, "\n# "
        got = "'#{got}'"
      @err "#          got: #{got}"

      if _.isString want
        want = want.replace /^/mg, '# '
        want = want.replace /^\#\ /, ''
        want = want.replace /\n$/, "\n# "
        want = "'#{want}'"
      @err "#     expected: #{want}"

  diag: (msg)->
    @err msg.replace /^/mg, '# '

  done_testing: ->
    @out "1..#{@count}"

# vim: ft=coffee sw=2:
