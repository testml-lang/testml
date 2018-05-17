use strict; use warnings;
package TestMLBridge;
use TestML::Bridge;
use base 'TestML::Bridge';

use Capture::Tiny 'capture_merged';

sub prove {
  my ($self, $testml_file) = @_;

  my $output = capture_merged {
    system "prove -v $testml_file";
  };

  $output =~ s/\ +$//mg;
  $output =~ s/^Files=.*\n//m;

  return $output;
}

sub run_cli {
  my ($self, $runner, $testml_file) = @_;

  my $output = capture_merged {
    system "$runner $testml_file";
  };

  $output =~ s/\ +$//mg;

  return $output;
}

1;
