class TestMLFunction {
  has Array $.func;
}

class TestML::Run {

use JSON::Tiny;

has $!vtable = {
  '==' => [
    'assert-eq',
    'assert-%1-eq-%2', {
      'str,str' => '',
      'num,num' => '',
      'bool,bool' => '',
    }
  ],
  '~~' => [
    'assert-has',
    'assert-%1-has-%2', {
      'str,str' => '',
      'str,str' => '',
      'str,list' => '',
      'list,str' => '',
      'list,list' => '',
    }
  ],
  '=~' => [
    'assert-like',
    'assert-%1-like-%2', {
      'str,str' => '',
      'str,regex' => '',
      'str,list' => '',
      'list,regex' => '',
      'list,list' => '',
    }
  ],

  '.'    => 'exec-dot',
  '%'    => 'each-exec',
  '%<>'  => 'each-pick',
  '<>'   => 'pick-exec',
  '&'    => 'call-func',

  Q[$''] => 'get-str',
  ':'    => 'get-hash',
  '[]'   => 'get-list',
  '*'    => 'get-point',

  '='    => 'set-var',
  '||='  => 'or-set-var',
};

has $!types = {
  '=>' => 'func',
  '/' => 'regex',
  '!' => 'error',
  '?' => 'native',
};

has Str $!file;
has Str $!version;
has Array $!code;
has Array $.data;

has $!bridge;
has $!stdlib;

has $!vars = {};
has $.block;
has $!warned-only = False;
has $!error;
has $.thrown is rw;

#------------------------------------------------------------------------------
method new(:$file='', :$testml={}, :$bridge, :$stdlib) {
  my $self = self.bless:
    file => $file,
    bridge => $bridge,
    stdlib => $stdlib;

  $!version = $testml<testml> if $testml<testml>;
  $!code = $testml<code> if $testml<code>;
  $!data = $testml<data> if $testml<data>;

  return $self;
}

method from-file($file) {
  $!file = $file;

  my $testml = from-json slurp $!file;
  ($!version, $!code, $!data) = $testml<testml code data>;

  self;
}

method test {
  self.test-begin;

  for |$!code -> $statement {
    self.exec-expr($statement);
  }

  self.test-end;

  return;
}

#------------------------------------------------------------------------------
method exec($expr) {
  self.exec-expr($expr)[0];
}

method exec-expr($expr, $context=[]) {
  return [$expr] unless self.type($expr) eq 'expr';

  my @args = @$expr.clone;
  my @return;
  my $name = @args.shift;
  my $opcode = $name;
  if my $call = $!vtable{$opcode} {
    $call = $call[0] if $call ~~ Array;
    @return = self."$call"(|@args);
  }
  else {
    @args.unshift($_) for $context.reverse;

    if (my $value = $!vars{$name}).defined {
      if (@args) {
        die "Variable '$name' has args but is not a function"
          unless self.type($value) eq 'func';
        @return = self.exec-func($value, @args);
      }
      else {
        @return = ($value);
      }
    }
    elsif $name ~~ /^<[a..z]>/ {
      @return = self.call-bridge($name, |@args);
    }
    elsif ($name ~~ /^<[A..Z]>/) {
      @return = self.call-stdlib($name, |@args);
    }
    else {
      die "Can't resolve TestML function '$name'";
    }
  }

  return @return;
}

method exec-func($function, $args is copy = []) {
  my ($op, $signature, $statements) = $function;

  if $signature > 1 and $args == 1 and self.type($args) eq 'list' {
    $args = $args[0];
  }

  die "TestML function expected '{$signature.Int}' arguments, but was called with '{$args.Int}' arguments"
    if $signature != $args;

  my $i = 0;
  for @$signature -> $v {
    $!vars{$v} = $args[$i++];
  }

  for @$statements -> $statement {
    self.exec-expr($statement);
  }

  return;
}

#------------------------------------------------------------------------------
method call-bridge($name, +@args) {
  $!bridge ||= (require ::(%*ENV<TESTML_BRIDGE>)).new;

  my $call = $name;

  die "Can't find bridge function: '$name'"
    unless $!bridge.can($call);

  @args = [ @args.map: { self.uncook(self.exec($_)) } ];

  my @return = $!bridge."$call"(|@args);

  return unless @return;

  self.cook(@return[0]);
}

method call-stdlib($name, +@args) {
  $!stdlib ||=  (require ::("TestML::StdLib")).new:
    run => self;

  my $call = $name.lc;
  die "Unknown TestML Standard Library function: '$name'"
    unless $!stdlib.can($call);

  @args = [ @args.map: { self.uncook(self.exec($_)) }, ];

  self.cook($!stdlib."$call"(|@args));
}

#------------------------------------------------------------------------------
method assert-eq($left, $right, $label='') {
  my $got = $!vars<Got> = self.exec($left);
  my $want = $!vars<Want> = self.exec($right);
  my $method = self.get-method('==', $got, $want);
  self."$method"($got, $want, $label);
  return;
}

method assert-str-eq-str($got, $want, $label) {
  self.testml-eq($got, $want, self.get-label($label));
}

method assert-num-eq-num($got, $want, $label) {
  self.testml-eq($got, $want, self.get-label($label));
}

method assert-bool-eq-bool($got, $want, $label) {
  self.testml-eq($got, $want, self.get-label($label));
}


method assert-has($left, $right, $label='') {
  my $got = self.exec($left);
  my $want = self.exec($right);
  my $method = self.get-method('~~', $got, $want);
  self."$method"($got, $want, $label);
  return;
}

method assert-str-has-str($got, $want, $label) {
  $!vars<Got> = $got;
  $!vars<Want> = $want;
  self.testml-has($got, $want, self.get-label($label));
}

method assert-str-has-list($got, $want, $label) {
  my $list = $want[0];
  for @$list -> $str {
    self.assert-str-has-str($got, $str, $label);
  }
}

method assert-list-has-str($got, $want, $label) {
  $!vars<Got> = $got;
  $!vars<Want> = $want;
  self.testml-list-has($got[0], $want, self.get-label($label));
}

method assert-list-has-list($got, $want, $label) {
  my $list = $want[0];
  for @$list -> $str {
    self.assert-list-has-str($got, $str, $label);
  }
}


method assert-like($left, $right, $label='') {
  my $got = self.exec($left);
  my $want = self.exec($right);
  my $method = self.get-method('=~', $got, $want);
  self."$method"($got, $want, $label);
  return;
}

method assert-str-like-regex($got, $want, $label) {
  $!vars<Got> = $got;
  $!vars<Want> = "/{$want[1]}/";
  my $regex = self.uncook($want);
  self.testml-like($got, $regex, self.get-label($label));
}

method assert-str-like-list($got, $want, $label) {
  my $list = $want[0];
  for @$list -> $regex {
    self.assert-str-like-regex($got, $regex, $label);
  }
}

method assert-list-like-regex($got, $want, $label) {
  my $list = $got[0];
  for @$list -> $str {
    self.assert-str-like-regex($str, $want, $label);
  }
}

method assert-list-like-list($got, $want, $label) {
  my $list-got = $got[0];
  my $list-want = $want[0];
  for @$list-got -> $str {
    for @$list-want -> $regex {
      self.assert-str-like-regex($str, $regex, $label);
    }
  }
}

#------------------------------------------------------------------------------
method exec-dot(+@args) {
  my $context = [];

  $!error = Nil;
  for |@args -> $call {
    if not $!error {
      my $e;
      try {
        if self.type($call) eq 'func' {
          self.exec-func($call, $context[0]);
          $context = [];
        }
        else {
          $context = self.exec-expr($call, $context);
        }
        CATCH {
          default {
            $e = .message;
            warn "$e\n{.backtrace}" if %*ENV<TESTML_DEVEL>;
          }
        }
      }
      if $e {
        $!error = self.call-stdlib('Error', "$e");
      }
      elsif ($!thrown) {
        $!error = self.cook($!thrown);
        $!thrown = Nil;
      }
    }
    else {
      if $call[0] eq 'Catch' {
        $context = [$!error];
        $!error = Nil;
      }
    }
  }

  die "Uncaught Error: {$!error[1].msg}"
    if $!error;

  return |$context;
}

method each-exec($list is copy, $expr is copy) {
  $list = self.exec($list);
  $expr = self.exec($expr);

  $list = $list[0];
  for @$list -> $item {
    $!vars<_> = [$item];
    if self.type($expr) eq 'func' {
      if $expr[1].elems == 0 {
        self.exec-func($expr);
      }
      else {
        self.exec-func($expr, [$item,]);
      }
    }
    else {
      self.exec_expr($expr);
    }
  }
}

method each-pick($list, $expr) {
  for |$!data -> $block {
    $!block = $block;

    self.exec-expr(['<>', $list, $expr]);
  }

  $!block = Nil;

  return;
}

method pick-exec($list, $expr) {
  my $pick = True;
  for |$list -> $point {
    if ($point ~~ /^\*/ and
        not $!block<point>{substr($point, 1)}:exists) or
       ($point ~~ /^\!\*/ and
        $!block<point>{substr($point, 2)}:exists
    ) {
      $pick = False;
      last;
    }
  }

  if $pick {
    if self.type($expr) eq 'func' {
      self.exec-func($expr);
    }
    else {
      self.exec-expr($expr);
    }
  }

  return;
}

method call-func($func is copy) {
  my $name = $func[0];
  $func = self.exec($func);
  die "Tried to call '$name' but is not a function"
    unless defined $func and self.type($func) eq 'func';
  self.exec-func($func);
}

method get-str($string) {
  self.interpolate($string);
}

method get-hash($hash, $key) {
  my $h = self.exec($hash);
  my $k = self.exec($key);
  self.cook($h[0]{$k});
}

method get-list($list is copy, $index) {
  $list = self.exec($list);
  return $[] if not $list[0];
  self.cook($list[0][$index]);
}

method get-point($name) {
  return self.getp($name);
}

method set-var($name, $expr) {
  self.setv($name, self.exec($expr));

  return;
}

method or-set-var($name, $expr) {
  return if defined $!vars{$name};

  if self.type($expr) eq 'func' {
    self.setv($name, $expr);
  }
  else {
    self.setv($name, self.exec($expr));
  }
  return;
}

#------------------------------------------------------------------------------
method getp($name) {
  return unless $!block;
  my $value = $!block<point>{$name};
  self.exec($value) if $value.defined;
}

method getv($name) {
  $!vars{$name};
}

method setv($name, $value) {
  $!vars{$name} = $value;
  return;
}

#------------------------------------------------------------------------------
method type ($value) {
  return 'null' if not $value.defined;
  return 'str' if $value ~~ Str;
  return 'bool' if $value ~~ Bool;
  return 'num' if $value ~~ Int | Num;
  if $value ~~ Array {
    return 'none' if $value.elems == 0;
    return $_ if $_ = $!types{$value[0]};
    return 'list' if $value[0] ~~ Array;
    return 'hash' if $value[0] ~~ Hash;
    return 'expr';
  }

  die "Can't determine type of this value:", $value.gist;
}

method cook($value=Empty) {
  return [] if $value ~~ Empty;
  return Nil if not $value.defined;
  return $value if $value ~~ Str | Bool | Num | Int;
  return $[$value] if $value ~~ Hash | Array;
  return $['/', $value] if $value ~~ Regex;
  return $['!', $value] if $value.WHAT.^name eq 'TestMLError';
  return $value.func if $value.WHAT.^name eq 'TestMLFunction';
  return $['?', $value];
  die 42;
}

method uncook($value) {
  use MONKEY;

  my $type = self.type($value);

  return $value if $type ~~ 'str' | 'num' | 'bool' | 'null';
  return $value[0] if $type ~~ 'list' | 'hash';
  return $value[1] if $type ~~ 'error' | 'native';
  return TestMLFunction.new(func => $value) if $type eq 'func';
  if $type eq 'regex' {
    if $value[1] ~~ Str {
      my $regex = $value[1];
      return EVAL "rx:P5/{$regex}/";
    }
    return $value[1];
  }
  return Empty if $type eq 'none';

  die "Can't uncook this value of type '$type': {$value.gist}"
}

#------------------------------------------------------------------------------
method get-method($key, +@args) {
  my @sig;
  for |@args -> $arg {
    push @sig, self.type($arg);
  }
  my $sig-str = @sig.join(',');

  my $entry = $!vtable{$key};
  my ($name, $pattern, $vtable) = @$entry;
  my $method = $!vtable{$sig-str};
  if not $method {
    $method = $pattern;
    $method ~~ s:g/\%(\d+)/@sig[$0 - 1]/;
  };

  die "Can't resolve $name($sig-str)" unless $method;
  die "Method '$method' does not exist" unless self.can($method);

  return $method;
}

method get-label($label-expr='') {
  my $label = self.exec($label-expr);

  $label ||= self.getv('Label') || '';

  my $block-label = $!block ?? $!block<label> !! '';

  if $label {
    $label ~~ s/^\+/$block-label/;
    $label ~~ s/\+$/$block-label/;
    $label ~~ s/\{\+\}/$block-label/;
  }
  else {
    $label = $block-label;
  }

  return self.interpolate($label, True);
}

method interpolate($string is copy, $label?) {
  $string ~~ s:g/\{(<[\w\-]>+)\}/{self.transform1($0, $label)}/;
  $string ~~ s:g/\{\*(<[\w\-]>+)\}/{self.transform2($0, $label)}/;

  return $string;
}

method transform($value is copy, $label) {
  my $type = self.type($value);
  if ($label) {
    if $type ~~ 'list' | 'hash' {
      return to-json($value[0]);
    }
    else {
      $value ~~ s:g/\n/␤/;
      return "$value";
    }
  }
  else {
    if ($type ~~ 'list' | 'hash') {
      return to-json($value[0]);
    }
    else {
      return "$value";
    }
  }
}

method transform1($name, $label) {
  my $value = $!vars{$name} // return '';
  self.transform($value, $label);
}

method transform2($name, $label) {
  return '' unless $.block;
  my $value = $.block<point>{$name} // return '';
  self.transform($value, $label);
}

} # class TestML::Run
