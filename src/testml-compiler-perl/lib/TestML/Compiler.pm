use strict; use warnings;
package TestML::Compiler;

our $VERSION = '0.0.1';

use TestML::Compiler::Grammar;
use TestML::Compiler::AST;

use Pegex::Parser;
use JSON::PP;

# use XXX;

sub parse_testml {
  my ($testml_input, $testml_file, $importer) = @_;

  my $parser = Pegex::Parser->new(
    grammar => TestML::Compiler::Grammar->new,
    receiver => TestML::Compiler::AST->new(
      file => $testml_file,
      importer => $importer,
    ),
    debug => $ENV{TESTML_COMPILER_DEBUG},
  );

  return $parser->parse($testml_input);
}

sub new {
  my ($class, $options) = @_;
  $options ||= {};

  return bless {
    ast => undef,
    importer => $options->{importer},
  }, $class;
}

sub compile {
  my ($self, $testml_input, $testml_file) = @_;
  $testml_file = '-' unless defined $testml_file;

  if ($ENV{TESTML_COMPILER_GRAMMAR_PRINT}) {
    my $grammar = TestML::Compiler::DevGrammar->new;
    $grammar->make_tree;
    print encode_json $grammar->{tree};
    exit 0;
  }

  $testml_input =~ s/\n?\z/\n/
    if length $testml_input;

  $self->ast_to_json(
    parse_testml(
      $testml_input,
      $testml_file,
      \&importer,
    )
  );
}

sub importer {
  my ($self, $name, $from) = @_;

  my $root;
  if ($from eq '-' or $from !~ /\//) {
    $root = '.';
  }
  else {
    $root = $from;
    $root =~ s/^(.*)\/.*/$1/;
  }

  my @lib = grep length,
    split(':', ($ENV{TESTML_LIB} || '')), $root;

  my $testml_file;
  for my $lib (@lib) {
    $testml_file = "$lib/$name.tml";
    last if -e "$lib/$name.tml";
    $testml_file = '';
  }
  if (not $testml_file) {
    die "Can't find '$name.tml' in:\n" .
      join '', map "- '$_'\n", @lib;
  }
  my $testml_input = file_read($testml_file);

  my $parse = parse_testml(
    $testml_input,
    $testml_file,
    \&importer,
  );

  for my $block (@{$parse->{data}}) {
    $block->{Name} = $name;
  }

  return $parse;
}

sub ast_to_json {
  my ($self, $ast) = @_;

  my $json = JSON::PP->new->pretty->space_before(0)->indent_length(2)->encode($ast);

  $json =~ s/\[([^\{\[]+?)\]/$_ = $1; s{\n *}{}g; "[$_]"/ge;
  $json =~ s/\ \[\n +"/ ["/g;
  $json =~ s/("=>",)\n *(\[[^\n]*\])/$1$2/g;
  $json =~ s/("\\"",)\n */$1/g;
  $json =~ s/\n *([\}\]])/$1/g;
  $json =~ s/^(\ +\["%<>",)\n\ +/$1/mg;
  $json =~ s/\ \[\n +\[/ [[/g;
  $json =~ s/^(\ +"code": \[)\[/$1\n    [/m;
  $json =~ s/(\{)\n +("(?:testml|label)":)/$1 $2/g;
  $json =~ s/^(\ +\{)\n\ +\"/$1 "/mg;
  $json =~ s/("=",)\n\ */$1/g;

  return $json;
}

sub file_read {
  my ($filename) = @_;

  open my $fh, $filename
    or die "Can't open '$filename' for input";

  local $/;

  return <$fh>
}

# vim: sw=2:
