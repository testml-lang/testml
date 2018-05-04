use strict; use warnings;
package Bridge;
use TestMLBridge;
use base 'TestMLBridge';

sub add {
  my ($self, $a, $b) = @_;

  return $a + $b;
}

sub sub {
  my ($self, $a, $b) = @_;

  return $a - $b;
}

1;
