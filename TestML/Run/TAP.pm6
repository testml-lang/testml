use TestML::Run;
use TestML::TAP;

unit class TestML::Run::TAP is TestML::Run;

has TestML::TAP $.tap = TestML::TAP.new;

method run($file) {
  self.new.from-file($file).test;
  return;
}

method test-begin {
}

method test-end {
  $.tap.done;
  return;
}

method testml-eq($got, $want, $label) {
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

method testml-like($got, $want, $label) {
  # self.check-plan;
  $.tap.like($got, $want, $label);
}

method testml-has($got, $want, $label) {
  # self.check-plan;

  if (index($got, $want) !~~ Nil) {
    self.tap.pass($label);
  }
  else {
    self.tap.fail($label);
    self.tap.diag("     this string: $got\n  doesn't contain: $want");
  }
}

method testml-list-has($got, $want, $label) {
  # self.check-plan;

  for @$got -> $str {
    next unless $str ~~ Str;
    if $str eq $want {
      self.tap.pass($label);
      return;
    }
  }
  self.tap.fail($label);
  self.tap.diag("     this list: {$got.perl}\n  doesn't contain: $want");
}
