use strict; use warnings;
package TestMLBridge;
use TestML::Bridge;
use base 'TestML::Bridge';

use Capture::Tiny 'capture_merged';

sub _clean {
  my ($output) = @_;

  $output =~ s/\ +$//mg;
  $output =~ s/^Files=.*\n//m;
  $output =~ s/Ran (\d+) tests in .+s/Ran $1 tests in ...s/;

  return $output;
}

sub prove {
  my ($self, $testml_file) = @_;

  _clean capture_merged {
    system "prove -v $testml_file";
  };
}

sub run_command {
  my ($self, $command) = @_;

  $ENV{LANG} = 'C';
  delete $ENV{TESTML_FILE};
  delete $ENV{TESTML_BIN};
  delete $ENV{TESTML_LANG};
  delete $ENV{TESTML_LANG_BIN};
  delete $ENV{TESTML_MODULE};
  delete $ENV{TESTML_BRIDGE};
#   for (keys %ENV) { delete $ENV{$_} if /TESTML_/ }

  _clean capture_merged {
    system "$command";
  };
}

sub cat {
  my ($self, $x, $y) = @_;
  return $x . $y;
}

sub add {
  my ($self, $x, $y) = @_;
  return $x + $y;
}

sub sub {
  my ($self, $x, $y) = @_;
  return $x - $y;
}

sub plus {
  my ($self, $x, $y) = @_;
  return $x + $y;
}

1;
