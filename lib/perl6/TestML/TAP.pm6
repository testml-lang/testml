class TestML::TAP {

has $.count is rw = 0;

method plan($plan) {
  self.out("1..$plan\n");
}

method pass($label) {
  my $label_ = $label;
  $label_ = " - $label_" if $label;
  self.out("ok {++$.count}$label_");
  return;
}

method fail($label) {
  my $label_ = $label;
  $label_ = " - $label_" if $label;
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

method show($got-prefix, $got, $want-prefix, $want, $label) {
  if $label {
    self.err("#   Failed test '$label'");
  }
  else {
    self.err("#   Failed test");
  }

  my $got_ = $got;
  if $got_ ~~ Str {
    $got_ = "'{$got_}'"
  }
  self.diag("$got-prefix $got_");

  my $want_ = $want;
  if $want_ ~~ Str {
    $want_ = "'{$want_}'"
  }
  self.diag("$want-prefix $want_");
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
