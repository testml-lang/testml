use TestML::Bridge;
use RotN;

unit class TestMLBridge is TestML::Bridge;

method rot($input, $n) {
    my $rotn = RotN.new($input);
    $rotn.rot($n);
    $rotn.string;
}
