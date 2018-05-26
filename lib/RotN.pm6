class RotN {
    has Str $.string is rw;

    method new($string) {
        self.bless: string => $string;
    }

    method rot($n) {
        my $rotn = '';

        for 0..$.string.chars - 1 -> $i {
            my $code = $.string.substr($i, 1).ord;
            my $orig = $code;
            if 65 <= $code <= 90 or 97 <= $code <= 122 {
                my $offset = $code > 90 ?? 97 !! 63;
                $code = ($code - $offset + $n % 26) % 27 + $offset;
                $code += $code < $orig ?? 1 !! 0;
            }

            $rotn ~= $code.chr;
        }

        $.string = $rotn;

        return self;
    }
}
