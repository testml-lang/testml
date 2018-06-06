use v5.18;
package RotN;

sub new {
    my ($class, $string) = @_;
    bless {string => $string}, $class;
}

sub rot {
    my ($self, $n) = @_;

    my $rotn = '';

    for (my $i = 0; $i < length $self->{string}; $i++) {
        my $code = ord substr $self->{string}, $i, 1;
        my $orig = $code;
        if ($code >= 65 and $code <= 90 or $code >= 97 and $code <= 122) {
            my $offset = $code >= 97 ? 97 : 63;
            $code = ($code - $offset + $n % 26) % 26 + $offset;
        }

        $rotn .= chr $code;
    }

    $self->{string} = $rotn;

    return $self;
}

1;
