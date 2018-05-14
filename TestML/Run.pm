class TestML::Block {
  has $.label;
  has $.point;
}

class TestML::Run {

use JSON::Tiny;

has Hash $.testml;
has Str $.testml-file;
has Array $.code;
has Array $.data;
has $.bridge is rw;
has TestML::Block $.block is rw;

my $operator = {
  '=='    => 'eq',
  '.'     => 'call',
  '=>'    => 'func',
  '%()'   => 'pickloop',
  '*'     => 'point',
};

method new($testml-file=Nil, $bridge=Nil) {
  return self.bless:
    testml-file => $testml-file,
    bridge => $bridge;
}

method from-file($testml-file) {
  $!testml-file = $testml-file;

  $!testml = from-json slurp $!testml-file;

  return self;
}

method initialize {
  $!code = $.testml<code>;

  $.code.unshift('=>', []);

  $!data = [
    $.testml<data>.map: {
      TestML::Block.new(|$_);
    }
  ];

  if not $.bridge {
    require ::(%*ENV<TESTML_BRIDGE>);

    $.bridge = ::(%*ENV<TESTML_BRIDGE>).new;
  }
}

method test {
  self.initialize;

  self.test-begin;

  self.exec: $.code;

  self.test-end;
}

method exec($expr, $context=[]) {
  return [$expr] unless $expr ~~ Array;

  my @args = @$expr.clone;
  my @return;
  my $call = @args.shift;
  if my $name = $operator{$call} {
    @return = self."exec-$name"(|@args);
  }
  else {
    @args = @args.map: {
      $_ ~~ Array ?? self.exec($_)[0] !! $_;
    };

    @args.unshift($_) for $context.reverse;

    if $call ~~ /^<[a..z]>/ {
      die "Can't find bridge function: '$call'"
        unless $.bridge.can($call);
      @return = $.bridge."$call"(|@args);
    }
    elsif ($call ~~ /^<[A..Z]>/) {
      $call = $call.lc;
      die "Unknown TestML Standard Library function: '$call'"
        unless $.stdlib.can($call);
      @return = $.stdlib."$call"(|@args);
    }
    else {
      die "Can't resolve TestML function '$call'";
    }
  }

  return @return;
}

method exec-call(*@args) {
  my $context = [];

  for |@args -> $call {
    $context = self.exec($call, $context);
  }

  return |$context;
}

method exec-eq($left, $right) {
  my $got = self.exec($left)[0];

  my $want = self.exec($right)[0];

  self.test-eq($got, $want, $.block.label);
}

method exec-func(*@args) {
  my $signature = @args.shift;

  for @args -> $statement {
    self.exec($statement);
  }
}

method exec-pickloop($list, $expr) {
  outer: for |$.data -> $block {
    for |$list -> $point {
      if $point ~~ /^\*/ {
        next outer unless $block.point{substr($point, 1)}:exists;
      }
      elsif $point ~~ /^\!\*/ {
        next outer if $block.point{substr($point, 2)}:exists;
      }
    }
    $.block = $block;
    self.exec($expr);
  }

  $.block = Nil;
}

method exec-point($name) {
  $.block.point{$name};
}

} # class TestML::Run
