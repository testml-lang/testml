use TestML::Run;
use Test::Builder;

unit class TestML::Run::TAP is TestML::Run;

has Test::Builder $.tap = Test::Builder.new;

method run($file) {
  self.new.from-file($file).test;
  return;
}

method test-begin {
  $.tap.plan(*);
  return;
}

method test-end {
  $.tap.done;
  return;
}

method test-eq($got, $want, $label) {
  if $want ~~ Str and
    $got ne $want and
    $want ~~ /\n/ and (
      self.getv('Diff') or
      self.getp('DIFF')
    ) {
    $.tap.is: $got, $want, $label;

    $.tap.diag("Diff requested but not available yet in Perl 6");
  }
  else {
    $.tap.is: $got, $want, $label;
  }

  return;
}
