package TestML::Compiler::AST;

# use JSON::PP; sub JJJ {die encode_json [@_]}

use Pegex::Base;
extends 'Pegex::Tree';

use Tie::IxHash;

has file => undef;
has importer => undef;

has code => [];
has data => [];
has point => {};
has transforms => {};

# These attach extra properties for statements and expressions.
# They are keyed on the ARRAY REF memory address of the expression.
my $attach = {};
sub attach {
  my ($expr, $type, $object, $tie) = @_;
  tie %$object, $tie if $tie;
  $attach->{$expr} = $expr;
  return $attach->{$type}{$expr} = $object;
}
sub detach {
  my ($type, $expr) = @_;
  delete $attach->{$expr};
  return delete($attach->{$type}{$expr});
}

sub final {
  my ($self) = @_;

  my $got = {};
  tie %$got, 'Tie::IxHash';
  %$got = (
    testml => '0.3.0',
    code => [],
    data => [],
  );

  for my $statement (@{$self->{code}}) {
    if (ref($statement) eq 'HASH') {
      if (my $imports = $statement->{imports}) {
        for my $ast (@$imports) {
          die "Can't import code after data started"
            if @{$ast->{code}} and @{$got->{data}};
          push @{$got->{code}}, @{$ast->{code}};
          push @{$got->{data}}, @{$ast->{data}};
        }
      }
    }
    else {
      if ($statement->[0] eq '<>') {
        $statement->[0] = '%<>';
      }
      elsif ($statement->[0] eq '=>') {
        for my $s (@{$statement->[2]}) {
          if ($s->[0] eq '<>') {
            $statement = ['%<>', [], $statement];
            last;
          }
        }
      }
      elsif ($statement->[0] eq '%') {
        my $pick = detach(pick => $statement) || {};
        my @keys = keys %$pick;
        if (@keys) {
          $statement = ['%<>', [@keys], $statement];
        }
      }

      push @{$got->{code}}, $statement;
    }
  }

  push @{$got->{data}}, @{$self->make_data($self->{data})};

  return $got;
}

sub got_code_section {
  my ($self, $got) = @_;

  $self->{code} = $got;

  return;
}

sub got_import_directive {
  my ($self, $got) = @_;

  my ($name, $more) = @{$got->[0]};
  my $names = [$name];
  for my $name (@$more) {
    push @$names, $name->[0] if defined $name->[0];
  }

  my $imports = [];
  my $importer = $self->importer;
  for my $name (@$names) {
    push @$imports, $importer->($self, $name, $self->file);
  }

  return {imports => $imports};
}

sub got_assignment_statement {
  my ($self, $got) = @_;

  my ($variable, $operator) = @{$got->[0]};
  my $expression = $got->[1];

  return [$operator, $variable, $expression];
}

sub got_loop_statement {
  my ($self, $got) = @_;
  my $expr = $got->[0];
  my $pick = detach(pick => $expr) || {};
  return ['%<>', [keys %$pick], $expr];
}

sub got_pick_statement {
  my ($self, $got) = @_;
  my ($pick, $statement) = @$got;
  return ['<>', $pick, $statement]
}

sub got_expression_statement {
  my ($self, $got) = @_;

  my $label;
  if (ref($got->[0]) eq 'HASH') {
    $label = shift @$got;
  }

  my ($left, $right, $suffix_label) = @$got;

  if (not $suffix_label and ref($right) eq 'HASH') {
    $suffix_label = $right;
    $right = undef;
  }

  my $pick = {};
  tie %$pick, 'Tie::IxHash';

  my $statement;
  if (defined $right) {
    my $key1 = $left;
    my $key2 = $right;
    $right->[1] = $left;
    $statement = $right;
    %$pick = (
      %{detach(pick => $key1) || {}},
      %{detach(pick => $key2) || {}},
    );
  }
  else {
    $statement = $left;
  }

  if (defined $label) {
    push @$statement, $label->{label};
  }
  elsif (defined $suffix_label) {
    push @$statement, $suffix_label->{label};
  }

  $pick = [keys %$pick];
  if (@$pick > 0) {
    $statement = ['<>', $pick, $statement]
  }

  return $statement;
}

sub got_expression_label {
  my ($self, $got) = @_;
  return { label => $got };
}

sub got_suffix_label {
  my ($self, $got) = @_;
  return { label => $got };
}

sub got_pick_expression {
  my ($self, $got) = @_;
  $got = $got->[0];
  my $pick = {};
  tie %$pick, 'Tie::IxHash';
  $pick->{shift(@$got)} = 1;
  my $more = $got->[0];
  for my $item (@$more) {
    next unless @$item;
    $pick->{$item->[0]} = 1;
  }
  return [keys %$pick];
}

sub got_code_expression {
  my ($self, $got) = @_;

  my ($object, $calls, $each) = @$got;
  my $expr = [($object), @$calls];

  my $pick = {};
  tie %$pick, 'Tie::IxHash';
  for my $e (@$expr) {
    my $k = $e;     # Copy prevents number being coerced to string.
    %$pick = (%$pick, %{detach(pick => $k) || {}});
  }

  if (@$expr == 1) {
    $expr = $expr->[0];
    if (detach(callable => $object)) {
      $expr = ['&', $expr];
    }
  }
  else {
    $expr = ['.', @$expr];
  }

  if (defined $each) {
    $expr = ['%', $expr, $each];
  }

  if (ref($expr) eq 'ARRAY') {
    attach($expr, pick => $pick);
  }

  return $expr;
}

sub got_point_object {
  my ($self, $got) = @_;
  my ($name, $indices) = @$got;
  my $object = ['*', $name];

  $indices ||= [];
  for my $elem (@$indices) {
    my ($opcode, $index) = @$elem;
    $object = [$opcode, $object, $index];
  }

  attach($object, pick => {"*$name" => 1});

  return $object;
}

sub got_double_string {
  my ($self, $got) = @_;
  my $value = $self->decode($got);
  $value = ['"', $value]
    if $value =~ /^(?:\\\\|[^\\])*?\{/;
  return $value;
}

sub got_number_object {
  my ($self, $got) = @_;
  return $got + 0;
}

sub got_regex_object {
  my ($self, $got) = @_;
  return ['/', $got];
}

sub got_list_object {
  my ($self, $got) = @_;
  $got = $got->[0];
  my $list = [];
  my ($first, $rest) = @$got;
  $rest = [
    grep $_, map $_->[0], @$rest
  ];
  if (defined $first) {
    push @$list, $first;
    for my $item (@$rest) {
      push @$list, $item;
    }
  }
  return [$list];
}

sub got_function_object {
  my ($self, $got) = @_;
  my $signature = @$got == 2
    ? shift(@$got)->[0]
    : [];

  unshift @$got, '=>', $signature;

  my $pick = attach($got, pick => {}, 'Tie::IxHash');
  for my $item (@$signature) {
    $pick->{$item} = 1 if $item =~ /^\*/;
  }

  return $got;
}

sub got_callable_function_object {
  my ($self, $got) = @_;

  return $self->got_function_object($got);
}

sub got_function_variables {
  my ($self, $got) = @_;
  my $vars = [shift @$got];
  return [] unless @$got;
  my $more = $got->[0];
  for my $item (@$more) {
    next unless @$item;
    push @$vars, $item->[0];
  }

  return $vars;
}

sub got_call_object {
  my ($self, $got) = @_;
  my ($name, $args, $indices) = @$got;

  if (defined $args and detach(indices => $args)) {
    $indices = $args;
    undef $args;
  }

  my $callable = (defined($args) and @$args == 0) ? 1 : 0;
  $args ||= [];
  $indices ||= [];
  my $object = [$name, @$args];

  for my $item (@$indices) {
    my ($opcode, $index) = @$item;
    $object = [$opcode, $object, $index];
  }

  my $pick = attach($object, pick => {}, 'Tie::IxHash');
  for my $a (@$args) {
    %$pick = (%$pick, %{detach(pick => $a) || {}});
  }

  attach($object, callable => $callable);

  return $object;
}

sub got_lookup_indices {
  my ($self, $got) = @_;

  my $indices = [
    map {
      my $opcode = ':';
      my $index =
        /^"(.*)"$/ ? ["\"", $1] :
        /^'(.*)'$/ ? $1 :
        /^\((.*)\)$/ ? [$1] :
        /^\[(.*)\]$/ ? do {
          $opcode = '[]';
          [$1];
        } :
        /^-?\d/ ? do {
          $opcode = '[]';
          my $num = $_;
          $num + 0;
        } : $_;
      [$opcode, $index];
    } @$got
  ];

  attach($indices, indices => 1);

  return $indices;
}

sub got_lookup_index {
  my ($self, $got) = @_;
  return $got->[0];
}

sub got_call_arguments {
  my ($self, $got) = @_;
  $got = $got->[0];
  my $args = [shift @$got];
  return [] unless @$got;
  my $more = $got->[0];
  for my $item (@$more) {
    next unless @$item;
    push @$args, $item->[0];
  }

  return $args;
}

sub got_assertion_expression {
  my ($self, $got) = @_;
  my ($operator, $expression) = @$got;
  my $assertion = [$operator, undef, $expression];
  attach($assertion, pick => detach(pick => $expression) || {});
  return $assertion;
}

sub got_block_definition {
  my ($self, $got) = @_;
  my ($label, $user, $points) = @$got;
  tie my %point, 'Tie::IxHash';
  for my $p (@$points) {
    my ($inherit, $name, $from, $has_transforms, $transforms, $value) = @$p;

    if ($name =~ /^(?:HEAD|LAST|ONLY|SKIP|TODO|DIFF)$/) {
      $point{$name} = bless(do{\(my $o = 1)}, 'JSON::PP::Boolean');
    }
    else {
      $point{$name} = $self->make_point(
        $name, $value,
        $inherit, $from,
        $has_transforms, $transforms,
      );
    }
  }

  $self->{data} ||= [];

  tie my %block, 'Tie::IxHash';
  %block = (
    label => $label,
    point => \%point,
  );

  $block{user} = $user if $user =~ /\S/;

  push @{$self->{data}}, \%block;

  return;
}

sub got_point_single {
  my ($self, $got) = @_;

  my $value = $got->[5];
  $value =~ s/^\ +//;

  if ($value =~ /^-?\d+(\.\d+)?$/) {
    $value = $value + 0;
  }
  elsif ($value =~ /^'(.*)'\s*$/) {
    $value = $1;
  }
  elsif ($value =~ /^"(.*)"\s*$/) {
    $value = $self->decode($1);
  }

  $got->[5] = $value;

  return $got;
}

sub got_comment_lines {
  my ($self, $got) = @_;
  return;
}

#------------------------------------------------------------------------------
my $decoder = {
  n => "\n",
  t => "\t",
  s => ' ',
  '\\' => '\\',
};

sub decode {
  my ($self, $str) = @_;
  $str =~ s/\\(.)/$decoder->{$1} || ''/ge;
  return $str;
}

sub make_point {
  my (
    $self, $name, $value,
    $inherit, $from,
    $has_transforms, $transform_expr,
  ) = @_;

  my $copy = $value;    # regex below will stringify numbers
  return $value if $copy =~ /^-?\d+(\.\d+)?$/;

  die "Can't use '--- $name=$from' without '^' in front"
    if $from and not $inherit;
  if ($inherit) {
    my $key = $from || $name;
    $value = $self->point->{$key} || '';

    if (not $has_transforms) {
      $transform_expr = $self->transforms->{$key} || '';
    }
  }
  else {
    $self->point->{$name} = $value;
  }

  my $transforms = { map {($_, 1)} split '', $transform_expr // '' };

  $self->transforms->{$name} = $transform_expr
    unless $inherit;

  if (not ref $value) {
    if (not $transforms->{'#'}) {
      $value =~ s/^#.*\n//gm;
    }

    if (not $transforms->{'+'} and $value =~ /\n/) {
      $value =~ s/\n+$/\n/;
      $value = '' if $value eq "\n";
    }

    if ($transforms->{'<'}) {
      $value =~ s/^    //gm;
    }

    if ($transforms->{'~'}) {
      $value =~ s/\n+/\n/g;
    }

    if ($transforms->{'@'}) {
      if ($value =~ /\n/) {
        $value =~ s/\n$//;
        $value = [split /\n/, $value];
      }
      else {
        $value = [split /\s+/, $value];
      }
      $value = [$value];
    }
    elsif ($transforms->{'%'}) {
      my @lines = split /\n/, $value;
      $value = {};
      for my $line (@lines) {
        next if $line =~ /^#/;
        next unless $line =~ /^(.+): (.+)$/;
        my ($key, $val) = ($1, $2);
        $val =~ s/'(.*)'/$1/;
        $val += 0 if $val =~ /^-?\d+(\.\d+)?$/;
        $value->{$key} = $val;
      }

      $value = [$value];
    }
    elsif ($transforms->{'-'}) {
      $value =~ s/\n$//;
    }
  }

  if ($transforms->{'"'}) {
    if (ref($value) eq 'ARRAY' and ref($value->[0]) eq 'ARRAY') {
      $value->[0] = [
        map {
          ref($_) ? $_ : $self->decode($_);
        } @{$value->[0]}
      ];
    }
    else {
      $value = $self->decode($value) if not ref $value;
    }
  }

  if ($transforms->{'/'}) {
    if (ref($value) eq 'ARRAY' and ref($value->[0]) eq 'ARRAY') {
      $value = [[map ['/', $_], @{$value->[0]}]];
    }
    else {
      my $flag = $value =~ /\n/ ? 'x' : '';
      $value =~ s/\n\z//;
      $value = ['/', $value];
      push @$value, $flag if $flag;
    }
  }

  if ($inherit and $from) {
    $self->point->{$name} = $value;
  }

  return $value;
}

sub make_data {
  my ($self, $data) = @_;

  my $blocks = [];

  for my $block (@$data) {
    if ($block->{point}{SKIP}) {
      next;
    }
    if ($block->{point}{ONLY}) {
      return [$block];
    }
    if ($block->{point}{HEAD}) {
      $blocks = [];
    }
    if ($block->{point}{LAST}) {
      push @$blocks, $block;
      return $blocks;
    }

    push @$blocks, $block;
  }

  return $blocks;
}

1;

# vim: sw=2:
