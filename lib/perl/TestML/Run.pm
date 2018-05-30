use strict; use warnings;
package TestML::Run;

use JSON::PP 'decode_json';

our $vtable = {
  '=='    => 'assert_eq',
  '~~'    => 'assert_has',
  '=~'    => 'assert_like',

  '.'     => 'exec_expr',
  '%()'   => 'pick_loop',
  '()'    => 'pick_exec',

  "\$''"  => 'get_str',
  '*'     => 'get_point',
  '='     => 'set_var',
};

sub block { $_[0]->{block} }

#------------------------------------------------------------------------------
sub new {
  my ($class, %params) = @_;

  my $testml = $params{testml};

  return bless {
    file => $params{file},
    version => $testml->{testml},
    code => $testml->{code},
    data => $testml->{data},
    bridge => $params{bridge},
    stdlib => $params{stdlib},
    vars => {},
  }, $class;
}

sub from_file {
  my ($self, $file) = @_;

  $self->{file} = $file;

  open INPUT, $file
    or die "Can't open '$file' for input";

  my $testml = decode_json do { local $/; <INPUT> };

  $self->{version} = $testml->{version};
  $self->{code} = $testml->{code};
  $self->{data} = $testml->{data};

  return $self;
}

sub test {
  my ($self) = @_;

  $self->initialize;

  $self->test_begin;

  $self->exec_func([], $self->{code});

  $self->test_end;

  return;
}

#------------------------------------------------------------------------------
sub getp {
  my ($self, $name) = @_;
  return unless $self->block;
  return $self->block->point->{$name};
}

sub getv {
  my ($self, $name) = @_;
  return $self->{vars}{$name};
}

sub setv {
  my ($self, $name, $value) = @_;
  $self->{vars}{$name} = $value;
  return;
}

#------------------------------------------------------------------------------
sub exec {
  my ($self, $expr, $context) = @_;

  $context //= [];

  return [$expr] if
    ref $expr ne 'ARRAY' or
    ref $expr->[0] eq 'ARRAY' or
    not ref $expr->[0] and $expr->[0] =~ /^(?:=>|\/|\?|\!)$/;

  my @args = @$expr;
  my @return;
  my $name = shift @args;
  my $opcode = $name;
  if (my $call = $vtable->{$opcode}) {
    @return = $self->$call(@args);
  }
  else {
    @args = map {
      ref eq 'ARRAY' ? $self->exec($_)->[0] : $_
    } @args;

    unshift @args, $_ for reverse @$context;

    if ($name =~ /^[a-z]/) {
      ($call = $name) =~ s/-/_/g;
      die "Can't find bridge function: '$name'"
        unless $self->{bridge}->can($call);
      @return = $self->{bridge}->$call(@args);
    }
    elsif ($name =~ /^[A-Z]/) {
      $call = lc $name;
      die "Unknown TestML Standard Library function: '$name'"
        unless $self->{stdlib}->can($call);
      @return = $self->{stdlib}->$call(@args);
    }
    else {
      die "Can't resolve TestML function '$name'";
    }
  }

  return [@return];
}

sub exec_func {
  my ($self, $context, $function) = @_;
  my $signature = shift @$function;

  for my $statement (@$function) {
    $self->exec($statement);
  }

  return;
}

sub exec_expr {
  my ($self, @args) = @_;

  my $context = [];

  for my $call (@args) {
    $context = $self->exec($call, $context);
  }

  return @$context;
}

sub pick_loop {
  my ($self, $list, $expr) = @_;

  for my $block (@{$self->{data}}) {
    $self->{block} = $block;

    $self->exec(['()', $list, $expr]);
  }

  delete $self->{block};

  return;
}

sub pick_exec {
  my ($self, $list, $expr) = @_;

  my $pick = 1;
  for my $point (@$list) {
    if (
      ($point =~ /^\*/ and
        not exists $self->block->point->{substr($point, 1)}) or
      ($point =~ /^!*/) and
        exists $self->block->point->{substr($point, 2)}
    ) {
      $pick = 0;
      last;
    }
  }

  if ($pick) {
    $self->exec($expr);
  }
}

sub get_str {
  my ($self, $string) = @_;

  $string =~ s{\{([\-\w+])\}} {
    $self->vars->{$1} || ''
  }gex;

  $string =~ s{\{\*([\-\w]+)\}} {
    $self->block->point->{$1} || ''
  }gex;

  return $string;
}

sub get_point {
  my ($self, $name) = @_;

  return $self->getp($name);
}

sub set_var {
  my ($self, $name, $expr) = @_;

  $self->setv($name, $self->exec($expr)->[0]);

  return;
}

sub assert_eq {
  my ($self, $left, $right, $label_expr) = @_;

  my $got = $self->exec($left)->[0];

  my $want = $self->exec($right)->[0];

  my $label = $self->get_label($label_expr);

  $self->test_eq($got, $want, $label);

  return;
}

#------------------------------------------------------------------------------
sub initialize {
  my ($self) = @_;

  unshift @{$self->{code}}, [];

  $self->{data} = [
    map {
      TestML::Block->new($_);
    } @{$self->{data}}
  ];

  if (not $self->{bridge}) {
    my $bridge_module = $ENV{TESTML_BRIDGE};
    eval "require $bridge_module; 1" or die "$@";
    $self->{bridge} = $bridge_module->new;
  }

  if (not $self->{stdlib}) {
    require TestML::StdLib;
    $self->{stdlib} = TestML::StdLib->new;
  }

  return;
}

sub get_label {
  my ($self, $label_expr) = @_;

  $label_expr //= '';

  my $label = $self->exec($label_expr)->[0];

  if (not $label) {
    $label = $self->getv('Label') || '';
    if ($label =~ /\{\*?[\-\w]+\}/) {
      $label = $self->exec(["\$''", $label])->[0];
    }
  }

  my $block_label = $self->block->label;

  if ($label) {
    $label =~ s/^\+/$block_label/;
    $label =~ s/\+$/$block_label/;
    $label =~ s/\{\+\}/$block_label/;
  }
  else {
    $label = $block_label;
  }

  return $label;
}

#------------------------------------------------------------------------------
package TestML::Block;

sub new {
  my ($class, $data) = @_;

  return bless $data, $class;
}

sub label { $_[0]->{label} }
sub point { $_[0]->{point} }

1;
