require '../../testml/run'

module.exports = Run = class extends TestML.Run
  @run: (file)->
    (new Run file).test()

  constructor: ->
    super(arguments...)

    @mocha = new require 'mocha'

    # @mocha.ui('bdd').ignoreLeaks()
    # @mocha.reporter('list').ui('bdd').ignoreLeaks()

  test_begin: ->

  test_end: ->

  test_eq: (got, want, label)->
    say label
    process.exit 1
