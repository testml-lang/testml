require '../testml'
require '../testml/prelude'
require '../testml/grammar'
require '../testml/ast'

require('pegex').require 'parser'

class TestML.Compiler
  ast: null

  compile: (input_path)->
    testml_input = read_file input_path

    parser = new Pegex.Parser
      grammar: new TestML.Grammar
      receiver: new TestML.AST
      debug: Boolean process.env.DEBUG

    ###
        Uncomment this and then run:
        ./bin/testml-compiler Makefile > new
        Then paste `new` into lib/testml/grammar.coffee
    ###
    # parser.grammar.make_tree()
    # jjj parser.grammar.tree

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
