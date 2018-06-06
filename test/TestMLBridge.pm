use v5.18;
package TestMLBridge;
use base 'TestML::Bridge';

use RotN;

sub rot {
    my ($self, $input, $n) = @_;
    my $rotn = RotN->new($input);
    $rotn->rot($n);
    $rotn->{string};
}

1;
