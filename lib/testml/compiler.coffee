require '../testml'
require '../testml/prelude'
require '../testml/grammar'
require '../testml/ast'

require('pegex').require 'parser'

class TestML.Compiler
  ast: null

  compile: (testml_input)->
    if TestML.node and process.env.TESTML_COMPILER_GRAMMAR_PRINT
      grammar = new TestML.DevGrammar
      grammar.make_tree()
      say JSON.stringify grammar.tree, null, 2
      exit 0

    parser = new Pegex.Parser
      grammar: new TestML.Grammar
      receiver: new TestML.AST
      debug: Boolean TestML.node and process.env.TESTML_COMPILER_DEBUG

    @ast_to_lingy parser.parse testml_input

  ast_to_lingy: (ast)->
    lingy = JSON.stringify ast, null, 2
    lingy = lingy.replace /\[([^\{\[]+?)\]/g, (m, m1)->
      "[#{m1.replace /\n */g, ''}]"
    lingy = lingy.replace /("=>",)\n *(\[[^\n]*\])/g, '$1$2'
    lingy = lingy.replace /\n *([\}\]])/g, '$1'
    lingy = lingy.replace /\[\n +"/g, '["'
    lingy = lingy.replace /^( *\["%\(\)",)\n *(\[.*\],)$/mg, '$1$2'
    lingy = lingy.replace /(\{)\n +("(?:testml|label)":)/g, '$1 $2'
    lingy + "\n"
