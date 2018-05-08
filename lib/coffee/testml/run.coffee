global.say = console.log
global._ = require 'lodash'

global.TestML ||= class

module.exports = class TestML.Run
  constructor: (testml_file)->
    testml = JSON.parse @read_file testml_file

    @code = testml.code

    @data = _.map testml.data, (block)->
      new TestML.Block block

  test: ->
    @test_begin()

    @exec @code

    @test_end()

  exec: (expr, context)->
    @test_eq 'foo', 'foo', 'foo == foo'

  read_file: (file_path)->
    fs = require 'fs'

    if file_path == '-'
      fs.readFileSync('/dev/stdin').toString()
    else
      fs.readFileSync(file_path).toString()

TestML.Block = class
  constructor: ({@label, @point})->
