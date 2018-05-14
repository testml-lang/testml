require '../testml'

module.exports = class TestML.TAP
  constructor: ->
    @count = 0
    @output = ''

    if TestML.browser
      @out = (text)->
        @output += text + "\n"
      @err = (text)->
        @output += text + "\n"

    else
      @out = (text)->
        process.stdout.write String(text) + "\n"
      @err = (text)->
        process.stderr.write String(text) + "\n"

  is_eq: (got, want, label)->
    @count++

    if got == want
      @out "ok #{@count} - #{label}"
    else
      @out "not ok #{@count} - #{label}"

      if label
        @err "#   Failed test '#{label}'"
      else
        @err "#   Failed test"

      got = got.replace /^/mg, '# '
      got = got.replace /^\#\ /, ''
      got = got.replace /\n$/, "\n# "
      @err "#          got: '#{got}'"

      want = want.replace /^/mg, '# '
      want = want.replace /^\#\ /, ''
      want = want.replace /\n$/, "\n# "
      @err "#     expected: '#{want}'"

  done_testing: ->
    @out "1..#{@count}"
