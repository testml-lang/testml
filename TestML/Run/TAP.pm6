use TestML::Run;

unit class TestML::Run::TAP is TestML::Run;

has $.count is rw = 0;

method run($file) {
  self.new.from-file($file).test;
  return;
}

method test-begin {
}

method test-end {
  self.tap-done;
  return;
}

method testml-eq($got, $want, $label) {
  if $want ~~ Str and
    $got ne $want and
    $want ~~ /\n/ and (
      self.getv('Diff') or
      self.getp('DIFF')
    ) {
    self.tap-is: $got, $want, $label;

    self.tap-diag("Diff requested but not available yet in Perl 6");
  }
  else {
    self.tap-is: $got, $want, $label;
  }

  return;
}

method testml-like($got, $want, $label) {
  # self.check-plan;
  self.tap-like($got, $want, $label);
}

method testml-has($got, $want, $label) {
  # self.check-plan;

  if (index($got, $want) !~~ Nil) {
    self.tap-pass($label);
  }
  else {
    self.tap-fail($label);
    self.tap-diag("     this string: $got\n  doesn't contain: $want");
  }
}

method testml-list-has($got, $want, $label) {
  # self.check-plan;

  for @$got -> $str {
    next unless $str ~~ Str;
    if $str eq $want {
      self.tap-pass($label);
      return;
    }
  }
  self.tap-fail($label);
  self.tap-diag("     this list: {$got.perl}\n  doesn't contain: $want");
}

method tap-plan($plan) {
  self.out("1..$plan\n");
}

method tap-pass($label is copy) {
  $label = " - $label" if $label;
  self.out("ok {++$.count}$label");
  return;
}

method tap-fail($label is copy) {
  $label = " - $label" if $label;
  self.out("not ok {++$.count}$label");
  return;
}

method tap-ok($ok, $label) {
  if $ok {
    self.tap-pass($label);
  }
  else {
    self.tap-fail($label);
  }
}

method tap-is($got, $want, $label, $diff=False) {
  my $ok =
  ($got.^name eq 'Str') ?? ($got eq $want) !!
  ($got.^name ~~ 'Int' | 'Num' | 'Bool') ?? ($got == $want) !!
    die "Can't do 'is' for type '{$got.^name}'";
  if $ok {
    self.tap-pass($label);
  }
  else {
    self.tap-fail($label);
    self.show-error('         got:', $got, '    expected:', $want, $label);
  }
}

method tap-like($got, $want, $label) {
  if $got ~~ $want {
    self.tap-pass($label);
  }
  else {
    self.tap-fail($label);
  }
}

method tap-diag($msg) {
  my $str = $msg;
  $str ~~ s:m:g/^/# /;
  self.err($str);
}

method tap-done {
  self.out("1..{$.count}");
}

method show-error($got-prefix, $got is copy, $want-prefix, $want is copy, $label) {
  if $label {
    self.err("#   Failed test '$label'");
  }
  else {
    self.err("#   Failed test");
  }

  if $got ~~ Str {
    $got = "'{$got}'"
  }
  self.diag("$got-prefix $got");

  if $want ~~ Str {
    $want = "'{$want}'"
  }
  self.diag("$want-prefix $want");
}

method out($str) {
  $*OUT.say($str);
  # $*OUT.flush;
}

method err($str) {
  $*ERR.say($str);
  # $*ERR.flush;
}
