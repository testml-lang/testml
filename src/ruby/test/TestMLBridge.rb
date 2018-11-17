use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

sub hash_lookup {
  my ($self, $hash, $key) = @_;
  $hash->{$key};
}

sub get_env {
  my ($self, $name) = @_;
  $ENV{$name};
}

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

sub mine {
  bless {}, 'Mine';
}

1;
