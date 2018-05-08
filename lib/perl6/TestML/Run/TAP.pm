use TestML::Run;
# use Test::Builder;
use Test; # XXX until Test::Builder is fixed

unit class TestML::Run::TAP is TestML::Run;

# has Test::Builder $.tap = Test::Builder.new;

method run($testml-file) {
  self.new($testml-file).test;
}

method test-begin {
#   $.tap.plan(*);
  plan(*);
}

method test-end {
#   $.tap.done;
  done-testing;
}

method test-eq($got, $want, $label) {
#   $.tap.is: "$got", "$want", $label;
  is("$got", "$want", $label);
}
