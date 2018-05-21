require '../../testml/run'

module.exports = class TestML.Run.Mocha extends TestML.Run
  @run: (file)->
    (new @).from_file(file).test()
    return

  constructor: (params={})->
    super(params)

    @browser = TestML.browser

    if @browser
      @assert = chai.assert
      @tests = []

    return

  test_begin: ->
    if @browser
      $('#mocha').html('')

      # Hack to reset Mocha internals, needed after first run.
      # https://github.com/mochajs/mocha/issues/2706#issuecomment-383233213
      mocha.suite = mocha.suite.clone()
      mocha.suite.ctx = new window.Mocha.Context()
      mocha.ui "bdd"

  test_end: ->
    if @browser
      run = ({got, want, label})->
        it label, ->
          chai.assert.equal got, want, label

      describe 'Mocha Tests', =>
        run test for test in @tests

      mocha.run()

  test_eq: (got, want, label)->
    if @browser
      @tests.push {got, want, label}

# vim: ft=coffee sw=2:
