use strict; use warnings;
package TestMLBridge;

sub new {
  my $class = shift;

  bless {@_}, $class;
}

1;
