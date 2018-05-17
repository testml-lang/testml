use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

sub add {
  my ($self, $a, $b) = @_;

  return $a + $b;
}

sub sub {
  my ($self, $a, $b) = @_;

  return $a - $b;
}

1;
