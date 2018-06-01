require('pegex').require 'grammar'

class TestMLCompiler.DevGrammar extends Pegex.Grammar
  constructor: ->
    super()
    @file = '../pegex/testml.pgx'

class TestMLCompiler.Grammar extends Pegex.Grammar
  constructor: ->
    super()
    @indents = ['']

  rule_indent: (parser, input, offset)->
    [..., indent] = @indents
    regex = "(?=(#{indent}\\ +)\\S)"
    return unless m = parser.match_rgx regex
    @indents.push m[0]
    return []

  rule_ondent: (parser, input, offset)->
    parser.match_ref 'comment_lines'

    [..., indent] = @indents
    regex = "#{indent}(?=\\S)"
    parser.match_rgx regex

  rule_undent: (parser, input, offset)->
    parser.match_ref 'comment_lines'

    return [] if input[offset..] == ''

    for i in [(@indents.length - 1)...-1]
      regex = "(?=#{@indents[i]}\\S)"
      if parser.match_rgx regex
        @indents.pop()
        return []

    return

  make_tree: ->
    {
      "+toprule": "testml_document",
      "testml_document": {
        ".all": [
          {
            ".ref": "head_section"
          },
          {
            ".ref": "code_section"
          },
          {
            ".ref": "data_section"
          }
        ]
      },
      "head_section": {
        ".all": [
          {
            ".ref": "comment_lines",
            "+min": 0
          },
          {
            ".ref": "testml_directive",
            "+max": 1
          },
          {
            ".ref": "head_statement",
            "+min": 0
          }
        ]
      },
      "comment_lines": {
        ".rgx": "(?:(?:\\#.*\\r?\\n)|(\\s*\\r?\\n|\\s+$))+"
      },
      "testml_directive": {
        ".rgx": "%TestML[\\ \\t]+([0-9]+\\.[0-9]+\\.[0-9]+)(?:;(?: (?=\\S))?|\\r?\\n?)"
      },
      "head_statement": {
        ".any": [
          {
            ".ref": "head_directive"
          },
          {
            ".ref": "comment_lines"
          }
        ]
      },
      "head_directive": {
        ".ref": "xxx"
      },
      "xxx": {
        ".rgx": "XXX"
      },
      "code_section": {
        ".ref": "code_statement",
        "+min": 0
      },
      "code_statement": {
        ".any": [
          {
            ".ref": "import_directive"
          },
          {
            ".ref": "comment_lines"
          },
          {
            ".ref": "assignment_statement"
          },
          {
            ".ref": "loop_statement"
          },
          {
            ".ref": "pick_statement"
          },
          {
            ".ref": "function_statement"
          },
          {
            ".ref": "expression_statement"
          }
        ]
      },
      "import_directive": {
        ".all": [
          {
            ".rgx": "%Import"
          },
          {
            ".ref": "__"
          },
          {
            ".all": [
              {
                ".ref": "module_name"
              },
              {
                ".all": [
                  {
                    ".ref": "__"
                  },
                  {
                    ".ref": "module_name"
                  }
                ],
                "+min": 0
              }
            ]
          },
          {
            ".ref": "ending"
          }
        ]
      },
      "__": {
        ".rgx": "[\\ \\t]+"
      },
      "module_name": {
        ".rgx": "(\\S+)"
      },
      "ending": {
        ".rgx": "(?:;(?: (?=\\S))?|\\r?\\n?)"
      },
      "assignment_statement": {
        ".all": [
          {
            ".rgx": "([a-zA-Z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*)[\\ \\t]+((?:=|\\|\\|=))[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
          },
          {
            ".ref": "ending"
          }
        ]
      },
      "code_expression": {
        ".all": [
          {
            ".ref": "code_object"
          },
          {
            ".ref": "function_call",
            "+min": 0
          },
          {
            ".ref": "each_call",
            "+max": 1
          }
        ]
      },
      "code_object": {
        ".any": [
          {
            ".ref": "point_object"
          },
          {
            ".ref": "string_object"
          },
          {
            ".ref": "number_object"
          },
          {
            ".ref": "regex_object"
          },
          {
            ".ref": "list_object"
          },
          {
            ".ref": "function_object"
          },
          {
            ".ref": "call_object"
          }
        ]
      },
      "point_object": {
        ".all": [
          {
            ".rgx": "\\*([a-z][\\-\\_a-z0-9]*)"
          },
          {
            ".ref": "lookup_indices"
          }
        ]
      },
      "lookup_indices": {
        ".ref": "lookup_index",
        "+min": 0
      },
      "lookup_index": {
        ".rgx": ":([a-zA-Z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*|(?:0|\\-?[1-9][0-9]*)|'((?:[^\\n\\\\']|\\\\[\\\\'])*?)'|\"((?:[^\\n\\\\\"]|\\\\[\\\\\"0nt])*?)\"|\\([a-zA-Z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*\\)|\\[[a-zA-Z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*\\])"
      },
      "string_object": {
        ".any": [
          {
            ".ref": "double_string"
          },
          {
            ".ref": "single_string"
          }
        ]
      },
      "double_string": {
        ".rgx": "\"((?:[^\\n\\\\\"]|\\\\[\\\\\"0nt])*?)\""
      },
      "single_string": {
        ".rgx": "'((?:[^\\n\\\\']|\\\\[\\\\'])*?)'"
      },
      "number_object": {
        ".rgx": "(\\-?[0-9]+(?:\\.[0-9]+)?)"
      },
      "regex_object": {
        ".rgx": "/((?:[^\\n\\\\/]|\\\\[\\\\/ntwds\\{\\}\\[\\]\\?\\*\\+])*?)/"
      },
      "list_object": {
        ".all": [
          {
            ".rgx": "\\["
          },
          {
            ".all": [
              {
                ".ref": "code_object"
              },
              {
                ".all": [
                  {
                    ".rgx": "[\\ \\t]*,[\\ \\t]*"
                  },
                  {
                    ".ref": "code_object"
                  }
                ],
                "+min": 0
              }
            ],
            "+max": 1
          },
          {
            ".rgx": "\\]"
          }
        ]
      },
      "function_object": {
        ".all": [
          {
            ".ref": "function_signature",
            "+max": 1
          },
          {
            ".rgx": "[\\ \\t]*=\\>(?:;(?: (?=\\S))?|\\r?\\n?)"
          },
          {
            ".ref": "indent",
            "-skip": 1
          },
          {
            ".all": [
              {
                ".ref": "ondent",
                "-skip": 1
              },
              {
                ".ref": "code_statement"
              }
            ],
            "+min": 1
          },
          {
            ".ref": "undent",
            "-skip": 1
          },
          {
            ".rgx": "(?=[\\s\\S]|$)"
          }
        ]
      },
      "function_signature": {
        ".all": [
          {
            ".rgx": "\\([\\ \\t]*"
          },
          {
            ".ref": "function_variables"
          },
          {
            ".rgx": "[\\ \\t]*\\)"
          }
        ]
      },
      "function_variables": {
        ".all": [
          {
            ".ref": "function_variable"
          },
          {
            ".all": [
              {
                ".rgx": ",[\\ \\t]*"
              },
              {
                ".ref": "function_variable"
              }
            ],
            "+min": 0
          }
        ],
        "+max": 1
      },
      "function_variable": {
        ".rgx": "([a-z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*|_)"
      },
      "call_object": {
        ".all": [
          {
            ".ref": "call_name"
          },
          {
            ".ref": "call_arguments",
            "+max": 1
          },
          {
            ".ref": "lookup_indices"
          }
        ]
      },
      "call_name": {
        ".rgx": "([a-zA-Z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*|_)"
      },
      "call_arguments": {
        ".all": [
          {
            ".ref": "LPAREN"
          },
          {
            ".all": [
              {
                ".ref": "code_expression"
              },
              {
                ".all": [
                  {
                    ".rgx": ",[\\ \\t]*"
                  },
                  {
                    ".ref": "code_expression"
                  }
                ],
                "+min": 0
              }
            ],
            "+max": 1
          },
          {
            ".ref": "RPAREN"
          }
        ]
      },
      "LPAREN": {
        ".rgx": "\\("
      },
      "RPAREN": {
        ".rgx": "\\)"
      },
      "function_call": {
        ".all": [
          {
            ".ref": "call_operator",
            "-skip": 1
          },
          {
            ".ref": "call_object"
          }
        ]
      },
      "call_operator": {
        ".ref": "DOT"
      },
      "DOT": {
        ".rgx": "\\."
      },
      "each_call": {
        ".all": [
          {
            ".rgx": "[\\ \\t]+%[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
          }
        ]
      },
      "loop_statement": {
        ".all": [
          {
            ".rgx": "%[\\ \\t]+"
          },
          {
            ".any": [
              {
                ".ref": "pick_statement"
              },
              {
                ".ref": "function_statement"
              },
              {
                ".ref": "expression_statement"
              }
            ]
          }
        ]
      },
      "pick_statement": {
        ".all": [
          {
            ".ref": "pick_expression"
          },
          {
            ".any": [
              {
                ".ref": "function_statement"
              },
              {
                ".ref": "expression_statement"
              }
            ]
          }
        ]
      },
      "pick_expression": {
        ".all": [
          {
            ".ref": "LANGLE"
          },
          {
            ".all": [
              {
                ".ref": "pick_argument"
              },
              {
                ".all": [
                  {
                    ".rgx": ",[\\ \\t]*"
                  },
                  {
                    ".ref": "pick_argument"
                  }
                ],
                "+min": 0
              }
            ]
          },
          {
            ".ref": "RANGLE"
          },
          {
            ".ref": "__"
          }
        ]
      },
      "LANGLE": {
        ".rgx": "<"
      },
      "pick_argument": {
        ".rgx": "(!?\\*[a-z][\\-\\_a-z0-9]*)"
      },
      "RANGLE": {
        ".rgx": ">"
      },
      "function_statement": {
        ".ref": "function_object"
      },
      "expression_statement": {
        ".all": [
          {
            ".ref": "expression_label",
            "+max": 1
          },
          {
            ".ref": "code_expression"
          },
          {
            ".ref": "assertion_expression",
            "+max": 1
          },
          {
            ".ref": "suffix_label",
            "+max": 1
          },
          {
            ".ref": "ending"
          }
        ]
      },
      "expression_label": {
        ".rgx": "\"((?:[^\\n\\\\\"]|\\\\[\\\\\"0nt])*?)\":\\s*"
      },
      "assertion_expression": {
        ".any": [
          {
            ".ref": "assertion_eq"
          },
          {
            ".ref": "assertion_has"
          },
          {
            ".ref": "assertion_like"
          }
        ]
      },
      "assertion_eq": {
        ".all": [
          {
            ".rgx": "[\\ \\t]+(==)[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
          }
        ]
      },
      "assertion_has": {
        ".all": [
          {
            ".rgx": "[\\ \\t]+(\\~\\~)[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
          }
        ]
      },
      "assertion_like": {
        ".all": [
          {
            ".rgx": "[\\ \\t]+(=\\~)[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
          }
        ]
      },
      "suffix_label": {
        ".rgx": "\\s*:\"((?:[^\\n\\\\\"]|\\\\[\\\\\"0nt])*?)\""
      },
      "data_section": {
        ".ref": "block_definition",
        "+min": 0
      },
      "block_definition": {
        ".all": [
          {
            ".ref": "block_heading"
          },
          {
            ".ref": "user_defined"
          },
          {
            ".ref": "point_definition",
            "+min": 0
          }
        ]
      },
      "block_heading": {
        ".rgx": "===(?:[\\ \\t]+(.*?)[\\ \\t]*)?\\r?\\n"
      },
      "user_defined": {
        ".rgx": "((?:.*\\r?\\n)*?(?=\\-\\-\\-|===|$))"
      },
      "point_definition": {
        ".any": [
          {
            ".ref": "point_single"
          },
          {
            ".ref": "point_multi"
          }
        ]
      },
      "point_single": {
        ".rgx": "\\-\\-\\-[\\ \\t]+(\\^?)((?:[a-z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF)))(?:=((?:[a-z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF))))?(?:(\\()([\\#\\+\\-\\~/\\@%]*)\\))?:[\\ \\t]+(.*?[\\ \\t]*)\\r?\\n(?:.*\\r?\\n)*?(?=\\-\\-\\-|===|$)"
      },
      "point_multi": {
        ".rgx": "\\-\\-\\-[\\ \\t]+(\\^?)((?:[a-z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF)))(?:=((?:[a-z][a-zA-Z0-9]*(?:\\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF))))?(?:(\\()([<\\#\\+\\-\\~/\\@%]*)\\))?\\r?\\n((?:.*\\r?\\n)*?(?=\\-\\-\\-|===|$))"
      }
    }
