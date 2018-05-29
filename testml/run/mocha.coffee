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

  testml_begin: ->
    if @browser
      $('#mocha').html('')

      # Hack to reset Mocha internals, needed after first run.
      # https://github.com/mochajs/mocha/issues/2706#issuecomment-383233213
      mocha.suite = mocha.suite.clone()
      mocha.suite.ctx = new window.Mocha.Context()
      mocha.ui "bdd"

  testml_end: ->
    if @browser
      run = ({got, want, label, assertion})->
        it label, ->
          chai.assert[assertion] got, want, label

      describe '', =>
        run test for test in @tests

      mocha.run()

  testml_eq: (got, want, label)->
    if @browser
      @tests.push {got, want, label, assertion: 'equal'}

  testml_like: (got, want, label)->
    if @browser
      want = new RegExp want
      @tests.push {got, want, label, assertion: 'match'}

  testml_has: (got, want, label)->
    if @browser
      @tests.push {got, want, label, assertion: 'include'}

  testml_list_has: (got, want, label)->
    if @browser
      @tests.push {got, want, label, assertion: 'include'}
