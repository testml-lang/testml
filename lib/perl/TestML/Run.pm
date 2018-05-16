use strict; use warnings;
package TestML::Run;

use JSON::PP 'decode_json';
# use XXX;

my $operator = {
  '=='    => 'eq',
  '.'     => 'call',
  '=>'    => 'func',
  '%()'   => 'pickloop',
  '*'     => 'point',
};

sub new {
  my ($class, $testml) = @_;

  return bless {
    testml => $testml,
  }, $class;
}

sub from_file {
  my ($self, $testml_file) = @_;

  $self->{testml_file} = $testml_file;

  $self->{testml} = decode_json $self->read_file($self->{testml_file});

  return $self;
}

sub test {
  my ($self) = @_;

  $self->initialize;

  $self->test_begin;

  $self->exec($self->{code});

  $self->test_end;
}

sub initialize {
  my ($self) = @_;

  $self->{code} = $self->{testml}{code};

  unshift @{$self->{code}}, '=>', [];

  $self->{data} = [
    map {
      TestML::Block->new($_);
    } @{$self->{testml}->{data}}
  ];

  if (not $self->{bridge}) {
    my $bridge_module = $ENV{TESTML_BRIDGE};
    eval "require $bridge_module; 1" || do {
      die "Can't find Bridge module for TestML"
        if $@ =~ /^Can't locate $bridge_module/;
      die $@;
    };

    $self->{bridge} = $bridge_module->new;
  }

  return $self;
}

sub exec {
  my ($self, $expr, $context) = @_;

  $context //= [];

  return [$expr] unless ref $expr eq 'ARRAY';

  my @args = @$expr;
  my @return;
  my $call = shift @args;
  if (my $name = $operator->{$call}) {
    $call = "exec_$name";
    @return = $self->$call(@args);
  }
  else {
    @args = map {
      ref eq 'ARRAY' ? $self->exec($_)->[0] : $_
    } @args;

    unshift @args, $_ for reverse @$context;

    if ($call =~ /^[a-z]/) {
      $call =~ s/-/_/g;
      die "Can't find bridge function: '$call'"
        unless $self->{bridge}->can($call);
      @return = $self->{bridge}->$call(@args);
    }
    elsif ($call =~ /^[A-Z]/) {
      $call = lc $call;
      die "Unknown TestML Standard Library function: '$call'"
        unless $self->stdlib->can($call);
      @return = $self->{stdlib}->$call(@args);
    }
    else {
      die "Can't resolve TestML function '$call'";
    }
  }

  die "Function '$call' returned more than one item"
    if @return > 1;

  return [@return];
}

sub exec_call {
  my ($self, @args) = @_;

  my $context = [];

  for my $call (@args) {
    $context = $self->exec($call, $context);
  }

  return @$context;
}

sub exec_eq {
  my ($self, $left, $right) = @_;

  my $got = $self->exec($left)->[0];

  my $want = $self->exec($right)->[0];

  $self->test_eq($got, $want, $self->{block}->label);
}

sub exec_func {
  my ($self, @args) = @_;
  my $signature = shift @args;

  for my $statement (@args) {
    $self->exec($statement);
  }

  return;
}

sub exec_pickloop {
  my ($self, $list, $expr) = @_;

  outer: for my $block (@{$self->{data}}) {
    for my $point (@$list) {
      if ($point =~ /^\*/) {
        next outer unless exists $block->{point}{substr($point, 1)};
      }
      elsif ($point =~ /^!*/) {
        next outer if exists $block->{point}{substr($point, 2)};
      }
    }
    $self->{block} = $block;
    $self->exec($expr);
  }

  delete $self->{block};
}

sub exec_point {
  my ($self, $name) = @_;

  $self->{block}{point}{$name};
}

sub read_file {
  my ($self, $file) = @_;

  open INPUT, $file
    or die "Can't open '$file' for input";

  local $/;
  my $input = <INPUT>;

  close INPUT;

  return $input;
}

package TestML::Block;
# use XXX;

sub new {
  my ($class, $data) = @_;

  return bless $data, $class;
}

sub label {
  my ($self) = @_;

  return $self->{label};
}

1;
