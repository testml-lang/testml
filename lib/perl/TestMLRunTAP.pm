use strict; use warnings;
package TestMLRunTAP;

use base 'TestMLRun';

use Test::Builder;
# use XXX;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  $self->{tap} = Test::Builder->new;

  return $self;
}

sub test_begin {
}

sub test_end {
  my ($self) = @_;

  $self->{tap}->done_testing;
}

sub test_eq {
  my ($self, $got, $want, $label) = @_;

  $self->{tap}->is_eq($got, $want, $label);
}

1;
