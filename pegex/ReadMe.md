Pegex
=====

An Acmeist PEG Framework

# Description

Pegex is a PEG (Parser Expression Grammar) framework where each low level match is a regular expression call. It is intended to work in all programming languages the support regular expressions.

Pegex attempts to make it very easy to write a Parser for a DSL (like JSON) and have it quickly work in every modern programming language.

Pegex uses a Pegex grammar to parse Pegex. This means it is "self-hosting". The current Pegex grammar for Pegex lives [here](https://github.com/ingydotnet/pegex-pgx/blob/master/pegex.pgx).

Pegex grammars can be precompiled to simple data structures that can be dumped to YAML or JSON. [Here](https://github.com/ingydotnet/pegex-pgx/blob/master/pegex.pgx.yaml) is the above Pegex Grammar (for Pegex) as YAML, and [here](https://github.com/ingydotnet/pegex-pgx/blob/master/pegex.pgx.json) it is as JSON.

As Pegex parsers match things, they call back the results to a "Receiver" class. The default receiver class will turn the parse events into a parse tree, also known as an AST. Receiver classes often organize parse data into structures needed by the next downstream process, however they are not limited to this.

# Pegex Implementations

Pegex is currently implemented in Perl, Ruby and CoffeeScript (thus JavaScript) and available on CPAN, RubyGems, and NPM respectively. A project called CafeScript is under way to make the CoffeeScript implementation, compile to many other languages.

# An Example Pegex Grammar

The [JSON Pegex Grammar](https://github.com/ingydotnet/json-pgx/blob/master/json.pgx) is small enough to show inline:

    # A simple grammar for the simple JSON data language.
    # See https://github.com/ingydotnet/pegex-json-pm for a Parser implementation
    # that uses this grammar.
    
    %grammar json
    %version 0.0.1
    
    json: map | seq
    
    node: map | seq | scalar
    
    map:
      / ~ LCURLY ~ /
      pair* % / ~ COMMA ~ /
      / ~ RCURLY ~ /
    
    pair:
      string
      / ~ COLON ~ /
      node
    
    seq:
      / ~ LSQUARE ~ /
      node* % / ~ COMMA ~ /
      / ~ RSQUARE ~ /
    
    scalar:
      string |
      number |
      boolean |
      null
    
    string: / # XXX Need to code this to spec.
      DOUBLE  # This works for simple cases,
        ((: # but doesn't handle all escaping yet.
          BACK BACK |
          BACK DOUBLE |
          [^ DOUBLE BREAK ]
        )*)
      DOUBLE
    /
    
    number: /(
      DASH?
      (: 0 | [1-9] DIGIT* )
      (: DOT DIGIT* )?
      (: [eE] [ DASH PLUS ]? DIGIT+ )?
    )/
    
    boolean: true | false
    
    true: /true/
    
    false: /false/
    
    null: /null/

The [Pegex::JSON](https://github.com/ingydotnet/pegex-json-pm) Perl JSON parsing module, uses this Receiver class:

    ##
    # name: Pegex::JSON::Data
    # abstract: Pegex Data Structure Builder for JSON
    # author: Ingy döt Net <ingy@cpan.org>
    # license: perl
    # copyright: 2018
    
    package Pegex::JSON::Data;
    use Pegex::Mo;
    extends 'Pegex::Receiver';
    
    use boolean;
    
    sub got_map { +{map @$_, map @$_, @{(pop)}} }
    sub got_seq { [map @$_, @{(pop)}] }
    
    sub got_string {
      my $string = pop;
      # XXX need to decode other string escapes here
      $string =~ s/\\n/\n/g;
      return $string;
    }
    
    sub got_number { $_[1] + 0 }
    sub got_true { &boolean::true }
    sub got_false { &boolean::false }
    sub got_null { undef }

Full documentation coming soon.

* [CPAN Pegex Module](http://search.cpan.org/perldoc?Pegex)
* [Pegex C'Dent/UniScript/CoffeeScript code](https://github.com/ingydotnet/pegex-cdent)
* [Pegex Grammar for Pegex](https://github.com/ingydotnet/pegex-pgx)
* [Pegex Grammar for JSON](https://github.com/ingydotnet/json-pgx)
* [Pegex Grammar for TestML](https://github.com/ingydotnet/testml-pgx)
