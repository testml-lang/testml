class TestML::TAP {

has $.count is rw = 0;

method plan($plan) {
  self.out("1..$plan\n");
}

method pass($label is copy) {
  $label = " - $label" if $label;
  self.out("ok {++$.count}$label");
  return;
}

method fail($label is copy) {
  $label = " - $label" if $label;
  self.out("not ok {++$.count}$label");
  return;
}

method ok($ok, $label) {
  if $ok {
    self.pass($label);
  }
  else {
    self.fail($label);
  }
}

method is($got, $want, $label, $diff=False) {
  my $ok =
  ($got.^name eq 'Str') ?? ($got eq $want) !!
  ($got.^name ~~ 'Int' | 'Num' | 'Bool') ?? ($got == $want) !!
    die "Can't do 'is' for type '{$got.^name}'";
  if $ok {
    self.pass($label);
  }
  else {
    self.fail($label);
    self.show('         got:', $got, '    expected:', $want, $label);
  }
}

method like($got, $want, $label) {
  if $got ~~ $want {
    self.pass($label);
  }
  else {
    self.fail($label);
  }
}

method diag($msg) {
  my $str = $msg;
  $str ~~ s:m:g/^/# /;
  self.err($str);
}

method done {
  self.out("1..{$.count}");
}

method show($got-prefix, $got is copy, $want-prefix, $want is copy, $label) {
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

}
