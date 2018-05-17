use strict; use warnings;
package TestML::Run::TAP;

use base 'TestML::Run';

use Test::Builder;
# use XXX;

sub run {
  my ($class, $testml_file) = @_;

  $class->new->from_file($testml_file)->test;
}

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

  if ($got ne $want and
      $want =~ /\n/ and (
        $self->getv('Diff') or
        $self->getp('DIFF')
      )
  ) {
    require Text::Diff;

    $self->{tap}->ok(0, $label);

    my $diff = Text::Diff::diff(
      \$want,
      \$got,
      {
        FILENAME_A => 'want',
        FILENAME_B => 'got',
      }
    );

    $self->{tap}->diag($diff);
  }
  else {
    $self->{tap}->is_eq($got, $want, $label);
  }
}

1;
