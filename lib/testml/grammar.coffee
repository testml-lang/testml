require('pegex').require 'grammar'

class TestML.DevGrammar extends Pegex.Grammar
  constructor: ->
    super()
    @file = 'share/testml.pgx'

class TestML.Grammar extends Pegex.Grammar
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
        ".rgx": "(?:(?:\\#.*\\r?\\n?)|(\\s*\\r?\\n|\\s+$))+"
      },
      "testml_directive": {
        ".rgx": "%TestML[\\ \\t]+([0-9]+\\.[0-9]+\\.[0-9]+)\\r?\\n?"
      },
      "head_statement": {
        ".any": [
          {
            ".ref": "directive_statement"
          },
          {
            ".ref": "comment_lines"
          }
        ]
      },
      "directive_statement": {
        ".ref": "import_directive"
      },
      "import_directive": {
        ".rgx": "%Import[\\ \\t]+(\\S+)\\r?\\n?"
      },
      "code_section": {
        ".ref": "code_statement",
        "+min": 0
      },
      "code_statement": {
        ".any": [
          {
            ".ref": "comment_lines"
          },
          {
            ".ref": "assignment_statement"
          },
          {
            ".ref": "expression_statement"
          }
        ]
      },
      "assignment_statement": {
        ".all": [
          {
            ".rgx": "([a-zA-Z][a-zA-Z0-9]*(?:\\-[a-zA-Z0-9]+)*)[\\ \\t]+((?:=|\\|\\|=))[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
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
            ".ref": "call_object"
          }
        ]
      },
      "point_object": {
        ".rgx": "\\*([a-z][\\-\\_a-z0-9]*)"
      },
      "string_object": {
        ".ref": "xxx"
      },
      "xxx": {
        ".rgx": "XXX"
      },
      "number_object": {
        ".rgx": "([0-9]+)"
      },
      "call_object": {
        ".all": [
          {
            ".ref": "call_name"
          },
          {
            ".ref": "call_arguments",
            "+max": 1
          }
        ]
      },
      "call_name": {
        ".rgx": "([a-zA-Z][a-zA-Z0-9]*(?:\\-[a-zA-Z0-9]+)*)"
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
      "expression_statement": {
        ".all": [
          {
            ".ref": "expression_label",
            "+max": 1
          },
          {
            ".ref": "pick_expression",
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
            ".ref": "eol"
          }
        ]
      },
      "expression_label": {
        ".ref": "xxx"
      },
      "pick_expression": {
        ".all": [
          {
            ".ref": "LPAREN"
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
            ".ref": "RPAREN"
          },
          {
            ".ref": "__"
          }
        ]
      },
      "pick_argument": {
        ".rgx": "(!?\\*[a-z][\\-\\_a-z0-9]*)"
      },
      "__": {
        ".rgx": "[\\ \\t]+"
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
            ".rgx": "[\\ \\t]+(==)[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
          }
        ]
      },
      "assertion_like": {
        ".all": [
          {
            ".rgx": "[\\ \\t]+(==)[\\ \\t]+"
          },
          {
            ".ref": "code_expression"
          }
        ]
      },
      "eol": {
        ".rgx": "\\r?\\n?"
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
        ".ref": "point_lines"
      },
      "point_lines": {
        ".rgx": "((?:.*\\r?\\n)*?)(?=\\-\\-\\-|===|$)"
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
        ".rgx": "\\-\\-\\-[\\ \\t]+((?:[a-z][a-zA-Z0-9]*(?:\\-[a-zA-Z0-9]+)*|(?:HEAD|LAST|ONLY|SKIP|TODO)))(\\S*):[\\ \\t]+(.*?[\\ \\t]*)\\r?\\n((?:.*\\r?\\n)*?)(?=\\-\\-\\-|===|$)"
      },
      "point_multi": {
        ".rgx": "\\-\\-\\-[\\ \\t]+((?:[a-z][a-zA-Z0-9]*(?:\\-[a-zA-Z0-9]+)*|(?:HEAD|LAST|ONLY|SKIP|TODO)))(\\S*)[\\ \\t]*\\r?\\n((?:.*\\r?\\n)*?)(?=\\-\\-\\-|===|$)"
      }
    }
