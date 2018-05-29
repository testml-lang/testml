#------------------------------------------------------------------------------
class TestML::Block {
  has $.label;
  has $.point;
}

#------------------------------------------------------------------------------
class TestML::Run {

use JSON::Tiny;

has $!vtable = {
  '=='    => 'assert-eq',
  '~~'    => 'assert-has',
  '=~'    => 'assert-like',

  '%()'   => 'pick-loop',
  '.'     => 'exec-expr',

  "\$''"  => 'get-str',
  '*'     => 'get-point',
  '='     => 'set-var',
};

has TestML::Block $.block;

has Str $!file;
has Str $!version;
has Array $!code;
has Array $!data;

has $!bridge;
has $!stdlib;

has $!vars;

method new(:$file='', :$testml={}, :$bridge, :$stdlib) {
  my $self = self.bless:
    file => $file,
    bridge => $bridge,
    stdlib => $stdlib,
    vars => {};

  $!version = $testml<testml> if $testml<testml>;
  $!code = $testml<code> if $testml<code>;
  $!data = $testml<data> if $testml<data>;

  return $self;
}

method from-file($file) {
  $!file = $file;

  my $testml = from-json slurp $!file;
  ($!version, $!code, $!data) = $testml<testml code data>;

  return self;
}

method test {
  self.initialize;

  self.test-begin;

  self.exec-func([], $!code);

  self.test-end;

  return;
}

#------------------------------------------------------------------------------
method getp($name) {
  return unless $.block;
  return $.block.point{$name};
}

method getv($name) {
  return $!vars{$name};
}

method setv($name, $value) {
  $!vars{$name} = $value;
  return;
}

#------------------------------------------------------------------------------
method exec($expr, $context=[]) {
  return [$expr] if
    not $expr ~~ Array or
    $expr[0] ~~ Array or
    $expr[0] ~~ Str and $expr[0] ~~ /^[\=\>|\/|\?|\!]$/;

  my @args = @$expr.clone;
  my @return;
  my $name = @args.shift;
  my $opcode = $name;
  if my $call = $!vtable{$opcode} {
    @return = self."$call"(|@args);
  }
  else {
    @args = @args.map: {
      $_ ~~ Array ?? self.exec($_)[0] !! $_;
    };

    @args.unshift($_) for $context.reverse;

    if $name ~~ /^<[a..z]>/ {
      my $call = $name;
      die "Can't find bridge function: '$name'"
        unless $!bridge.can($call);
      @return = $!bridge."$call"(|@args);
    }
    elsif ($name ~~ /^<[A..Z]>/) {
      $call = $name.lc;
      die "Unknown TestML Standard Library function: '$name'"
        unless $!stdlib.can($call);
      @return = $!stdlib."$call"(|@args);
    }
    else {
      die "Can't resolve TestML function '$name'";
    }
  }

  return @return;
}

method exec-func($context, @function) {
  my $signature = @function.shift;

  for @function -> $statement {
    self.exec($statement);
  }

  return;
}

method exec-expr(*@args) {
  my $context = [];

  for |@args -> $call {
    $context = self.exec($call, $context);
  }

  return |$context;
}

method pick-loop($list, $expr) {
  for |$!data -> $block {
    my $pick = True;
    for |$list -> $point {
      if ($point ~~ /^\*/ and not $block.point{substr($point, 1)}:exists) or
         ($point ~~ /^\!\*/ and $block.point{substr($point, 2)}:exists) {
        $pick = False;
        last;
      }
    }

    if $pick {
      $!block = $block;
      self.exec($expr);
    }
  }

  $!block = Nil;

  return;
}

method get-str($original) {
  my $string = $original;

  $string ~~ s/\{(<[\w\-]>+)\}/{$.vars{$0}}/;

  $string ~~ s:g/\{\*(<[\w\-]>+)\}/{$.block.point{$0}}/;

  return $string;
}

method get-point($name) {
  return self.getp($name);
}

method set-var($name, $expr) {
  self.setv($name, self.exec($expr)[0]);

  return;
}

method assert-eq($left, $right, $label-expr='') {
  my $got = self.exec($left)[0];

  my $want = self.exec($right)[0];

  my $label = self.get-label($label-expr);

  self.test-eq($got, $want, $label);

  return;
}

#------------------------------------------------------------------------------
method initialize {
  $!code.unshift([]);

  $!data = [
    $!data.map: {
      TestML::Block.new(|$_);
    }
  ];

  if not $!bridge {
    $!bridge = (require ::(%*ENV<TESTML_BRIDGE>)).new;
  }

  if not $!stdlib {
    require TestML::StdLib;
    $!stdlib = TestML::StdLib.new;
  }

  return;
}

method get-label($label-expr='') {
  my $label = self.exec($label-expr)[0];

  if not $label {
    $label = self.getv('Label') || '';
    if $label ~~ /\{\*?<[\w\-]>\}/ {
      $label = self.exec(["\$''", $label])[0];
    }
  }

  my $block-label = $.block.label;

  if $label {
    $label ~~ s/^\+/$block-label/;
    $label ~~ s/\+$/$block-label/;
    $label ~~ s/\{\+\}/$block-label/;
  }
  else {
    $label = $block-label;
  }

  return $label;
}

} # class TestML::Run
