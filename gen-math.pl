use strict; use warnings;
use YAML::XS;

my @data;
for my $i (1..(shift || 10)) {
    my $a = int rand 100;
    my $b = int rand 100;
    my $c = $a + $b;
    push @data, {
        _label => "Test $i",
        a => $a,
        b => $b,
        c => $c,
    };
}

print Dump \@data;
