use strict; use warnings;
package TestML::Run::TAP;

use base 'TestML::Run';

use Test::Builder;

sub run {
  my ($class, $file) = @_;
  $class->new->from_file($file)->test;
  return;
}

sub new {
  my ($class, @params) = @_;
  my $self = $class->SUPER::new(@params);

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

# vim: ft=perl sw=2:
