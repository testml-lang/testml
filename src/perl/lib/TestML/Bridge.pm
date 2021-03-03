use strict; use warnings;
package TestML::Bridge;

sub new {
  my $class = shift;

  bless {@_}, $class;
}

sub testml_block {
  return $_[0]->{run}{block};
}

1;
