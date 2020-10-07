# class TestMLCompiler.DevGrammar extends Pegex.Grammar
#   constructor: ->
#     super()
#     @file = '../testml-pgx/testml.pgx'

package TestML::Compiler::Grammar;
our $VERSION = '0.0.1';

use Pegex::Base;
extends 'Pegex::Grammar';

use constant file => '../testml-pgx/testml.pgx';

has indents => [''];

sub rule_indent {
  my ($self, $parser, $input, $offset) = @_;

  my $indent = $self->indents->[-1];
  my $regex = qr/\G(?=($indent\ +)\S)/;
  my $m = $parser->match_rgx($regex) or return;
  push @{$self->indents}, $m->[0];
  return [];
}

sub rule_ondent {
  my ($self, $parser, $input, $offset) = @_;
  $parser->match_ref('comment_lines');

  my $indent = $self->indents->[-1];
  my $regex = qr/\G$indent(?=\S)/;
  $parser->match_rgx($regex);
}

sub rule_undent {
  my ($self, $parser, $input, $offset) = @_;
  $parser->match_ref('comment_lines');

  return [] if $offset >= length $$input;

  for my $indent (reverse @{$self->{indents}}) {
    my $regex = qr/\G(?=$indent\S|\z)/;
    if ($parser->match_rgx($regex)) {
      pop @{$self->indents};
      return [];
    }
  }

  return;
}

sub make_tree {   # Generated/Inlined by Pegex::Grammar (0.75)
  {
    '+toprule' => 'testml_document',
    'DOT' => {
      '.rgx' => qr/\G\./
    },
    'LANGLE' => {
      '.rgx' => qr/\G</
    },
    'LPAREN' => {
      '.rgx' => qr/\G\(/
    },
    'RANGLE' => {
      '.rgx' => qr/\G\>/
    },
    'RPAREN' => {
      '.rgx' => qr/\G\)/
    },
    '__' => {
      '.rgx' => qr/\G[\ \t]+/
    },
    'assertion_expression' => {
      '.all' => [
        {
          '.rgx' => qr/\G[\ \t]+(==|=\~|\~\~|\!==|\!=\~|\!\~\~)[\ \t]+/
        },
        {
          '.ref' => 'code_expression'
        }
      ]
    },
    'assignment_statement' => {
      '.all' => [
        {
          '.rgx' => qr/\G([a-zA-Z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*)[\ \t]+((?:=|\|\|=))[\ \t]+/
        },
        {
          '.ref' => 'code_expression'
        },
        {
          '.ref' => 'ending'
        }
      ]
    },
    'block_definition' => {
      '.all' => [
        {
          '.ref' => 'block_heading'
        },
        {
          '.ref' => 'user_defined'
        },
        {
          '+min' => 0,
          '.ref' => 'point_definition'
        }
      ]
    },
    'block_heading' => {
      '.rgx' => qr/\G===(?:[\ \t]+(.*?)[\ \t]*)?\r?\n/
    },
    'bridge_code' => {
      '.rgx' => qr/\G((?:.*\r?\n)*?)(?=%Bridge|(?:(?:(?:\#.*\r?\n)|(?:\s*\r?\n|\s+\z))+)?===)(?:(?:(?:\#.*\r?\n)|(?:\s*\r?\n|\s+\z))+)?/
    },
    'bridge_definition' => {
      '.all' => [
        {
          '.ref' => 'bridge_directive'
        },
        {
          '.ref' => 'bridge_code'
        },
        {
          '+max' => 1,
          '.ref' => 'bridge_end'
        }
      ]
    },
    'bridge_directive' => {
      '.rgx' => qr/\G%Bridge[\ \t]+([a-z][a-z0-9]*|c\+\+)[\ \t]*\r?\n/
    },
    'bridge_end' => {
      '.rgx' => qr/\G%Bridge[\ \t]+end[\ \t]*\r?\n/
    },
    'bridge_section' => {
      '+min' => 0,
      '.ref' => 'bridge_definition'
    },
    'call_arguments' => {
      '.all' => [
        {
          '.ref' => 'LPAREN'
        },
        {
          '+max' => 1,
          '.all' => [
            {
              '.ref' => 'code_expression'
            },
            {
              '+min' => 0,
              '.all' => [
                {
                  '.rgx' => qr/\G,[\ \t]*/
                },
                {
                  '.ref' => 'code_expression'
                }
              ]
            }
          ]
        },
        {
          '.ref' => 'RPAREN'
        }
      ]
    },
    'call_name' => {
      '.rgx' => qr/\G([a-zA-Z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*|_)/
    },
    'call_object' => {
      '.all' => [
        {
          '.ref' => 'call_name'
        },
        {
          '+max' => 1,
          '.ref' => 'call_arguments'
        },
        {
          '.ref' => 'lookup_indices'
        }
      ]
    },
    'call_operator' => {
      '.ref' => 'DOT'
    },
    'callable_function_object' => {
      '.all' => [
        {
          '.ref' => 'function_signature'
        },
        {
          '.rgx' => qr/\G[\ \t]*=\>(?:;(?:\ (?=\S))?|[\ \t]*(?:\#.*\r?\n)|\r?\n?)/
        },
        {
          '-skip' => 1,
          '.ref' => 'indent'
        },
        {
          '+min' => 1,
          '.all' => [
            {
              '-skip' => 1,
              '.ref' => 'ondent'
            },
            {
              '.ref' => 'code_statement'
            }
          ]
        },
        {
          '-skip' => 1,
          '.ref' => 'undent'
        },
        {
          '.rgx' => qr/\G(?=[\s\S]|\z)/
        }
      ]
    },
    'code_expression' => {
      '.all' => [
        {
          '.ref' => 'code_object'
        },
        {
          '+min' => 0,
          '.ref' => 'function_call'
        },
        {
          '+max' => 1,
          '.ref' => 'each_call'
        }
      ]
    },
    'code_object' => {
      '.any' => [
        {
          '.ref' => 'point_object'
        },
        {
          '.ref' => 'string_object'
        },
        {
          '.ref' => 'number_object'
        },
        {
          '.ref' => 'regex_object'
        },
        {
          '.ref' => 'list_object'
        },
        {
          '.ref' => 'function_object'
        },
        {
          '.ref' => 'call_object'
        }
      ]
    },
    'code_section' => {
      '+min' => 0,
      '.ref' => 'code_statement'
    },
    'code_statement' => {
      '.any' => [
        {
          '.ref' => 'import_directive'
        },
        {
          '.ref' => 'comment_lines'
        },
        {
          '.ref' => 'assignment_statement'
        },
        {
          '.ref' => 'loop_statement'
        },
        {
          '.ref' => 'pick_statement'
        },
        {
          '.ref' => 'function_statement'
        },
        {
          '.ref' => 'expression_statement'
        }
      ]
    },
    'comment_lines' => {
      '.rgx' => qr/\G(?:(?:(?:\#.*\r?\n)|(?:\s*\r?\n|\s+\z))+)/
    },
    'data_section' => {
      '+min' => 0,
      '.ref' => 'block_definition'
    },
    'double_string' => {
      '.rgx' => qr/\G"((?:[^\n\\"]|\\[\\"0nt])*?)"/
    },
    'each_call' => {
      '.all' => [
        {
          '-skip' => 1,
          '.ref' => 'each_operator'
        },
        {
          '.ref' => 'code_expression'
        }
      ]
    },
    'each_operator' => {
      '.rgx' => qr/\G[\ \t]+%[\ \t]+/
    },
    'ending' => {
      '.rgx' => qr/\G(?:;(?:\ (?=\S))?|[\ \t]*(?:\#.*\r?\n)|\r?\n?)/
    },
    'expression_label' => {
      '.rgx' => qr/\G"((?:[^\n\\"]|\\[\\"0nt])*?)":\s*/
    },
    'expression_statement' => {
      '.all' => [
        {
          '+max' => 1,
          '.ref' => 'expression_label'
        },
        {
          '.ref' => 'code_expression'
        },
        {
          '+max' => 1,
          '.ref' => 'assertion_expression'
        },
        {
          '+max' => 1,
          '.ref' => 'suffix_label'
        },
        {
          '.ref' => 'ending'
        }
      ]
    },
    'function_call' => {
      '.all' => [
        {
          '-skip' => 1,
          '.ref' => 'call_operator'
        },
        {
          '.any' => [
            {
              '.ref' => 'call_object'
            },
            {
              '.ref' => 'callable_function_object'
            }
          ]
        }
      ]
    },
    'function_object' => {
      '.all' => [
        {
          '+max' => 1,
          '.ref' => 'function_signature'
        },
        {
          '.rgx' => qr/\G[\ \t]*=\>(?:;(?:\ (?=\S))?|[\ \t]*(?:\#.*\r?\n)|\r?\n?)/
        },
        {
          '-skip' => 1,
          '.ref' => 'indent'
        },
        {
          '+min' => 1,
          '.all' => [
            {
              '-skip' => 1,
              '.ref' => 'ondent'
            },
            {
              '.ref' => 'code_statement'
            }
          ]
        },
        {
          '-skip' => 1,
          '.ref' => 'undent'
        },
        {
          '.rgx' => qr/\G(?=[\s\S]|\z)/
        }
      ]
    },
    'function_signature' => {
      '.all' => [
        {
          '.rgx' => qr/\G\([\ \t]*/
        },
        {
          '.ref' => 'function_variables'
        },
        {
          '.rgx' => qr/\G[\ \t]*\)/
        }
      ]
    },
    'function_statement' => {
      '.ref' => 'function_object'
    },
    'function_variable' => {
      '.rgx' => qr/\G(\*?[a-z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*|_)/
    },
    'function_variables' => {
      '+max' => 1,
      '.all' => [
        {
          '.ref' => 'function_variable'
        },
        {
          '+min' => 0,
          '.all' => [
            {
              '.rgx' => qr/\G,[\ \t]*/
            },
            {
              '.ref' => 'function_variable'
            }
          ]
        }
      ]
    },
    'head_directive' => {
      '.ref' => 'xxx'
    },
    'head_section' => {
      '.all' => [
        {
          '+min' => 0,
          '.ref' => 'comment_lines'
        },
        {
          '+max' => 1,
          '.ref' => 'testml_directive'
        },
        {
          '+min' => 0,
          '.ref' => 'head_statement'
        }
      ]
    },
    'head_statement' => {
      '.any' => [
        {
          '.ref' => 'head_directive'
        },
        {
          '.ref' => 'comment_lines'
        }
      ]
    },
    'import_directive' => {
      '.all' => [
        {
          '.rgx' => qr/\G%Import/
        },
        {
          '.ref' => '__'
        },
        {
          '.all' => [
            {
              '.ref' => 'module_name'
            },
            {
              '+min' => 0,
              '.all' => [
                {
                  '.ref' => '__'
                },
                {
                  '.ref' => 'module_name'
                }
              ]
            }
          ]
        },
        {
          '.ref' => 'ending'
        }
      ]
    },
    'list_object' => {
      '.all' => [
        {
          '.rgx' => qr/\G\[/
        },
        {
          '+max' => 1,
          '.all' => [
            {
              '.ref' => 'code_object'
            },
            {
              '+min' => 0,
              '.all' => [
                {
                  '.rgx' => qr/\G[\ \t]*,[\ \t]*/
                },
                {
                  '.ref' => 'code_object'
                }
              ]
            }
          ]
        },
        {
          '.rgx' => qr/\G\]/
        }
      ]
    },
    'lookup_index' => {
      '.rgx' => qr/\G:([a-zA-Z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*|(?:0|\-?[1-9][0-9]*)|'((?:[^\n\\']|\\[\\'])*?)'|"((?:[^\n\\"]|\\[\\"0nt])*?)"|\([a-zA-Z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*\)|\[[a-zA-Z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*\])/
    },
    'lookup_indices' => {
      '+min' => 0,
      '.ref' => 'lookup_index'
    },
    'loop_statement' => {
      '.all' => [
        {
          '.rgx' => qr/\G%[\ \t]+/
        },
        {
          '.any' => [
            {
              '.ref' => 'pick_statement'
            },
            {
              '.ref' => 'function_statement'
            },
            {
              '.ref' => 'expression_statement'
            }
          ]
        }
      ]
    },
    'module_name' => {
      '.rgx' => qr/\G(\w\S*)/
    },
    'number_object' => {
      '.rgx' => qr/\G(\-?[0-9]+(?:\.[0-9]+)?)/
    },
    'pick_argument' => {
      '.rgx' => qr/\G(!?\*[a-z][\-\_a-z0-9]*)/
    },
    'pick_expression' => {
      '.all' => [
        {
          '.ref' => 'LANGLE'
        },
        {
          '.all' => [
            {
              '.ref' => 'pick_argument'
            },
            {
              '+min' => 0,
              '.all' => [
                {
                  '.rgx' => qr/\G,[\ \t]*/
                },
                {
                  '.ref' => 'pick_argument'
                }
              ]
            }
          ]
        },
        {
          '.ref' => 'RANGLE'
        },
        {
          '.ref' => '__'
        }
      ]
    },
    'pick_statement' => {
      '.all' => [
        {
          '.ref' => 'pick_expression'
        },
        {
          '.any' => [
            {
              '.ref' => 'function_statement'
            },
            {
              '.ref' => 'expression_statement'
            }
          ]
        }
      ]
    },
    'point_definition' => {
      '.any' => [
        {
          '.ref' => 'point_single'
        },
        {
          '.ref' => 'point_multi'
        }
      ]
    },
    'point_multi' => {
      '.rgx' => qr/\G\-\-\-[\ \t]+(\^?)((?:[a-z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF|WHEN)))(?:=((?:[a-z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF|WHEN))))?(?:(\()([<\#\+\-\~\"\/\@%]*)\))?\r?\n((?:.*\r?\n)*?(?=\-\-\-|===|\z))/
    },
    'point_object' => {
      '.all' => [
        {
          '.rgx' => qr/\G\*([a-z][\-\_a-z0-9]*)/
        },
        {
          '.ref' => 'lookup_indices'
        }
      ]
    },
    'point_single' => {
      '.rgx' => qr/\G\-\-\-[\ \t]+(\^?)((?:[a-z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF|WHEN)))(?:=((?:[a-z][a-zA-Z0-9]*(?:\-[a-zA-Z][a-zA-Z0-9]*)*|(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF|WHEN))))?(?:(\()([\#\+\-\~\/\@%]*)\))?:((?=\r?\n)|[\ \t]+(?:.*?[\ \t]*))\r?\n(?:.*\r?\n)*?(?=\-\-\-|===|\z)/
    },
    'regex_object' => {
      '.rgx' => qr/\G\/((?:[^\n\\\/]|\\[\\\/ntwds\{\}\[\]\?\*\+])*?)\//
    },
    'single_string' => {
      '.rgx' => qr/\G'((?:[^\n\\']|\\[\\'])*?)'/
    },
    'string_object' => {
      '.any' => [
        {
          '.ref' => 'double_string'
        },
        {
          '.ref' => 'single_string'
        }
      ]
    },
    'suffix_label' => {
      '.rgx' => qr/\G\s*:"((?:[^\n\\"]|\\[\\"0nt])*?)"/
    },
    'testml_directive' => {
      '.rgx' => qr/\G%TestML[\ \t]+([0-9]+\.[0-9]+\.[0-9]+)(?:;(?:\ (?=\S))?|[\ \t]*(?:\#.*\r?\n)|\r?\n?)/
    },
    'testml_document' => {
      '.all' => [
        {
          '.ref' => 'head_section'
        },
        {
          '.ref' => 'code_section'
        },
        {
          '.ref' => 'bridge_section'
        },
        {
          '.ref' => 'data_section'
        }
      ]
    },
    'user_defined' => {
      '.rgx' => qr/\G((?:.*\r?\n)*?(?=\-\-\-|===|\z))/
    },
    'xxx' => {
      '.rgx' => qr/\GXXX/
    }
  }
}

1;

# vim: sw=2:
