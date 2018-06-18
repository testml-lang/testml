require '../testml-compiler'
require '../testml-compiler/grammar'
require '../testml-compiler/ast'

require('pegex').require 'parser'

parse_testml = (testml_input, testml_file, importer)->
  parser = new Pegex.Parser
    grammar: new TestMLCompiler.Grammar
    receiver: new TestMLCompiler.AST
      file: testml_file
      importer: importer
    debug: Boolean TestMLCompiler.env.TESTML_COMPILER_DEBUG

  parser.parse testml_input

class TestMLCompiler.Compiler
  constructor: (options={})->
    {@importer} = options if options.importer?

  ast: null

  compile: (testml_input, testml_file='-')->
    if TestMLCompiler.env.TESTML_COMPILER_GRAMMAR_PRINT
      grammar = new TestMLCompiler.DevGrammar
      grammar.make_tree()
      say JSON.stringify grammar.tree, null, 2
      exit 0

    testml_input.replace /\n?$/, '\n' if testml_input.length

    @ast_to_json parse_testml testml_input, testml_file, @importer

  importer: (name, from)->
    if from == '-' or not from.match /\//
      root = '.'
    else
      root = from.replace /^(.*)\/.*/, '$1'

    testml_file = "#{root}/#{name}.tml"
    testml_input = file_read testml_file

    parse_testml testml_input, testml_file, @importer

  ast_to_json: (ast)->
    json = JSON.stringify ast, null, 2
    json = json.replace /\[([^\{\[]+?)\]/g, (m, m1)->
      "[#{m1.replace /\n */g, ''}]"
    json = json.replace /\ \[\n +"/g, ' ["'
    json = json.replace /("=>",)\n *(\[[^\n]*\])/g, '$1$2'
    json = json.replace /("\\"",)\n */g, '$1'
    json = json.replace /\n *([\}\]])/g, '$1'
    json = json.replace /^(\ +\["%<>",)\n\ +/mg, '$1'
    json = json.replace /\ \[\n +\[/g, ' [['
    json = json.replace /^(\ +"code": \[)\[/m, '$1\n    ['
    json = json.replace /(\{)\n +("(?:testml|label)":)/g, '$1 $2'
    json = json.replace /^(\ +\{)\n\ +\"/mg, '$1 "'
    json = json.replace /("=",)\n\ */g, '$1'
    json + "\n"
