use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

sub add {
  my ($self, $x, $y) = @_;

  $x + $y;
}

sub sub {
  my ($self, $x, $y) = @_;

  $x - $y;
}

sub cat {
  my ($self, $x, $y) = @_;

  $x . $y;
}

1;
