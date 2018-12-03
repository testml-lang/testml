require 'json'

class TestML
end
class TestML::Null
end

class TestML::Run

# use strict; use warnings;
# package TestMLFunction;

# sub new {
#   my ($class, $func) = @_;
#   return bless {func => $func}, $class;
# }

# package TestML::Run;

# use JSON::PP;

# use utf8;
# use TestML::Boolean;
# use Scalar::Util;

# # use XXX;

  @@Null = TestML::Null.new

  @@vtable = {
    '=='    => 'assert_eq',
    '~~'    => 'assert_has',
    '=~'    => 'assert_like',
    '!=='   => 'assert_not_eq',
    '!~~'   => 'assert_not_has',
    '!=~'   => 'assert_not_like',

    '.'     => 'exec_dot',
    '%'     => 'each_exec',
    '%<>'   => 'each_pick',
    '<>'    => 'pick_exec',
    '&'     => 'call_func',

    '"'     => 'get_str',
    ':'     => 'get_hash',
    '[]'    => 'get_list',
    '*'     => 'get_point',

    '='     => 'set_var',
    '||='   => 'or_set_var',
  }

  @@types = {
    '=>' => 'func',
    '/' => 'regex',
    '!' => 'error',
    '?' => 'native',
  }

# #------------------------------------------------------------------------------
  def initialize(params)
    @vars = {}

#   my $testml = $params{testml};

#   return bless {
#     file => $params{file},
#     ast => $params{testml},

#     bridge => $params{bridge},
#     stdlib => $params{stdlib},

#     vars => {},
#     block => undef,
#     warned_only => false,
#     error => undef,
#     thrown => undef,
#   }, $class;
  end

  def from_file(file)

    @file = file
    @ast = JSON.load File.read file
    return self

  end

  def test
    self.testml_begin


    @ast['code'].each do |statement|
      #require 'pry'; binding.pry
      self.exec_expr(statement)
    end

    self.testml_end

    return
  end

# #------------------------------------------------------------------------------
  def exec(expr)

    return self.exec_expr(expr)[0]
  end

  def exec_expr(expr, context=[])

    return [expr] unless self.type(expr) == 'expr'

    args = expr.clone
    name = args.shift
    opcode = name
    if call = @@vtable[ opcode ]
      call = call[0] if call.class == Array
      ret = self.public_send(call, *args)
    else
      args.unshift *context

      if (@vars.key? name)
        value = @vars[name]

        if args.length > 0
          throw "Variable '#{name}' has args but is not a function" \
            unless self.type(value) == 'func'
          ret = self.exec_func value, args
        else
          ret = [value]
        end
        throw ret

      elsif name.match /^[a-z]/
        ret = self.call_bridge name, *args
#     }
#     elsif ($name =~ /^[A-Z]/) {
#       @ret = $self->call_stdlib($name, @args);
#     }
#     else {
#       die "Can't resolve TestML function '$name'";
#     }
      end
    end

    return [*ret]
  end

# sub exec_func {
#   my ($self, $function, $args) = @_;
#   $args = [] unless defined $args;

#   my ($op, $signature, $statements) = @$function;

#   if (@$signature > 1 and @$args == 1 and $self->type($args) eq 'list') {
#     $args = $args->[0];
#   }

#   die "TestML function expected '${\scalar @$signature}' arguments, but was called with '${\scalar @$args}' arguments"
#     if @$signature != @$args;

#   my $i = 0;
#   for my $v (@$signature) {
#     $self->{vars}{$v} = $self->exec($args->[$i++]);
#   }

#   for my $statement (@$statements) {
#     $self->exec_expr($statement);
#   }

#   return;
# }

# #------------------------------------------------------------------------------
  def call_bridge(name, *args)

    if not @bridge
      bridge_module = ENV["TESTML_BRIDGE"]
      bridge_module = 'testml-bridge' if bridge_module == nil

      if @ast['bridge'] and @ast['bridge'].key? 'ruby'
        code = @ast['bridge']['ruby']
#       eval <<"..." or die $@;
# use strict; use warnings;
# package TestMLBridge;
# use base 'TestML::Bridge';
# $code;
# 1;
# ...
#     }
      else
        require bridge_module
      end

      @bridge = TestMLBridge.new
    end

    call = name.gsub /-/, '_'

    throw "Can't find bridge function: '#{name}'" \
      unless @bridge and @bridge.respond_to? call


    args = args.map { |arg| self.uncook self.exec arg }

    ret = @bridge.public_send call, *args

    return unless ret != nil

    self.cook(ret)
  end

# sub call_stdlib {
#   my ($self, $name, @args) = @_;

#   if (not $self->{stdlib}) {
#     require TestML::StdLib;
#     $self->{stdlib} = TestML::StdLib->new($self);
#   }

#   my $call = lc $name;
#   die "Unknown TestML Standard Library function: '$name'"
#     unless $self->{stdlib}->can($call);

#   @args = map {$self->uncook($self->exec($_))} @args;

#   $self->cook($self->{stdlib}->$call(@args));
# }

# #------------------------------------------------------------------------------
  def assert_eq(left, right, label=nil, not_=false)
    got = @vars["Got"] = self.exec(left)
    want = @vars["Want"] = self.exec(right)

    method = self.get_method('assert_%s_eq_%s', got, want)
    self.public_send method, got, want, label, not_

    return
  end

  def assert_str_eq_str(got, want, label, not_=false)
    self.testml_eq got, want, self.get_label(label), not_
  end

  def assert_num_eq_num(got, want, label, not_)
    self.testml_eq got, want, self.get_label(label), not_
  end

# sub assert_bool_eq_bool {
#   my ($self, $got, $want, $label, $not) = @_;
#   $self->testml_eq($got, $want, $self->get_label($label), $not);
# }


# sub assert_has {
#   my ($self, $left, $right, $label, $not) = @_;
#   my $got = $self->exec($left);
#   my $want = $self->exec($right);
#   my $method = $self->get_method('assert_%s_has_%s', $got, $want);
#   $self->$method($got, $want, $label, $not);
#   return;
# }

# sub assert_str_has_str {
#   my ($self, $got, $want, $label, $not) = @_;
#   $self->{vars}{Got} = $got;
#   $self->{vars}{Want} = $want;
#   $self->testml_has($got, $want, $self->get_label($label), $not);
# }

# sub assert_str_has_list {
#   my ($self, $got, $want, $label, $not) = @_;
#   for my $str (@{$want->[0]}) {
#     $self->assert_str_has_str($got, $str, $label, $not);
#   }
# }

# sub assert_list_has_str {
#   my ($self, $got, $want, $label, $not) = @_;
#   $self->{vars}{Got} = $got;
#   $self->{vars}{Want} = $want;
#   $self->testml_list_has($got->[0], $want, $self->get_label($label), $not);
# }

# sub assert_list_has_list {
#   my ($self, $got, $want, $label, $not) = @_;
#   for my $str (@{$want->[0]}) {
#     $self->assert_list_has_str($got, $str, $label, $not);
#   }
# }


# sub assert_like {
#   my ($self, $left, $right, $label, $not) = @_;
#   my $got = $self->exec($left);
#   my $want = $self->exec($right);
#   my $method = $self->get_method('assert_%s_like_%s', $got, $want);
#   $self->$method($got, $want, $label, $not);
#   return;
# }

# sub assert_str_like_regex {
#   my ($self, $got, $want, $label, $not) = @_;
#   $self->{vars}{Got} = $got;
#   $self->{vars}{Want} = "/${\ $want->[1]}/";
#   $want = $self->uncook($want);
#   $self->testml_like($got, $want, $self->get_label($label), $not);
# }

# sub assert_str_like_list {
#   my ($self, $got, $want, $label, $not) = @_;
#   for my $regex (@{$want->[0]}) {
#     $self->assert_str_like_regex($got, $regex, $label, $not);
#   }
# }

# sub assert_list_like_regex {
#   my ($self, $got, $want, $label, $not) = @_;
#   for my $str (@{$got->[0]}) {
#     $self->assert_str_like_regex($str, $want, $label, $not);
#   }
# }

# sub assert_list_like_list {
#   my ($self, $got, $want, $label, $not) = @_;
#   for my $str (@{$got->[0]}) {
#     for my $regex (@{$want->[0]}) {
#       $self->assert_str_like_regex($str, $regex, $label, $not);
#     }
#   }
# }

# sub assert_not_eq {
#   my ($self, $got, $want, $label) = @_;
#   $self->assert_eq($got, $want, $label, true);
# }

# sub assert_not_has {
#   my ($self, $got, $want, $label) = @_;
#   $self->assert_has($got, $want, $label, true);
# }

# sub assert_not_like {
#   my ($self, $got, $want, $label) = @_;
#   $self->assert_like($got, $want, $label, true);
# }

# #------------------------------------------------------------------------------
  def exec_dot(*args)

    context = []

    @error = nil

    args.each do |call|
#     if (not $self->{error}) {
#       eval {
          if self.type(call) == 'func'
            throw 'todo'
#           $self->exec_func($call, $context->[0]);
#           $context = [];
          else
            context = self.exec_expr call, context
          end
#       };
#       if ($@) {
#         if ($ENV{TESTML_DEVEL}) {
#             require Carp;
#             Carp::cluck($@);
#         }
#         $self->{error} = $self->call_stdlib('Error', "$@");
#       }
#       elsif ($self->{thrown}) {
#         $self->{error} = $self->cook(delete $self->{thrown});
#       }
#     }
#     else {
#       if ($call->[0] eq 'Catch') {
#         $context = [delete $self->{error}];
#       }
#     }
    end

#   die "Uncaught Error: ${\ $self->{error}[1]{msg}}"
#     if $self->{error};

    return context[0]
  end

# sub each_exec {
#   my ($self, $list, $expr) = @_;
#   $list = $self->exec($list);
#   $expr = $self->exec($expr);

#   for my $item (@{$list->[0]}) {
#     $self->{vars}{_} = [$item];
#     if ($self->type($expr) eq 'func') {
#       if (@{$expr->[1]} == 0) {
#         $self->exec_func($expr);
#       }
#       else {
#         $self->exec_func($expr, [$item]);
#       }
#     }
#     else {
#       $self->exec_expr($expr);
#     }
#   }
# }

  def each_pick(list, expr)

    @ast["data"].each do |block|
      @block = block
      self.exec_expr ['<>', list, expr]
    end

    @block = nil

    return
  end

  def pick_exec(list, expr)
    pick = true

    list.each do |point|
      if point.match /^\*/ and not @block["point"].key? point[1..-1] or
         point.match /^!*/ and @block["point"].key? point[2..-1]
        throw point
        pick = false
        break
      end
    end

    if pick
      if self.type(expr) == 'func'
        self.exec_func expr
      else
        self.exec_expr expr
      end
    end

    return
  end

# sub call_func {
#   my ($self, $func) = @_;
#   my $name = $func->[0];
#   $func = $self->exec($func);
#   die "Tried to call '$name' but is not a function"
#     unless defined $func and $self->type($func) eq 'func';
#   $self->exec_func($func);
# }

# sub get_str {
#   my ($self, $string) = @_;
#   $self->interpolate($string);
# }

# sub get_hash {
#   my ($self, $hash, $key) = @_;
#   $hash = $self->exec($hash);
#   $key = $self->exec($key);
#   $self->cook($hash->[0]{$key});
# }

# sub get_list {
#   my ($self, $list, $index) = @_;
#   $list = $self->exec($list);
#   return [] if not @{$list->[0]};
#   $self->cook($list->[0][$index]);
# }

  def get_point(name)
    return self.getp name
  end

# sub set_var {
#   my ($self, $name, $expr) = @_;

#   $self->setv($name, $self->exec($expr));

#   return;
# }

# sub or_set_var {
#   my ($self, $name, $expr) = @_;
#   return if defined $self->{vars}{$name};

#   if ($self->type($expr) eq 'func') {
#     $self->setv($name, $expr);
#   }
#   else {
#     $self->setv($name, $self->exec($expr));
#   }
#   return;
# }

# #------------------------------------------------------------------------------
  def getp(name)
    return unless @block
    value = @block["point"][name]
    value = self.exec value if defined? value
    return value
  end

# sub getv {
#   my ($self, $name) = @_;
#   $self->{vars}{$name};
# }

# sub setv {
#   my ($self, $name, $value) = @_;
#   $self->{vars}{$name} = $value;
#   return;
# }

# #------------------------------------------------------------------------------
  def type(value)

    return 'null' if value == nil

    if value.class == String
      return 'str'
    elsif value.kind_of? Integer
      return 'num'
    elsif value.class == Float
      return 'num'
    elsif value.class == TrueClass
      return 'bool'
    elsif value.class == FalseClass
      return 'bool'
    end

    if value.class == Array
      return 'none' if value.length == 0
      return @@types[ value[0] ] if @@types.key? value[0]
      return 'list' if value[0].class == Array
      return 'hash' if value[0].class == Hash
      return 'expr'
    end

    throw "Can't determine type of this value: '#{value}'"
  end

  def cook(value)

    return value if value.kind_of? Integer
    throw "not implemented yet"
#   return [] if not @value;
#   my $value = $value[0];
#   return undef if not defined $value;

#   return $value if not ref $value;
#   return [$value] if ref($value) =~ /^(?:HASH|ARRAY)$/;
#   return $value if isBoolean($value);
#   return ['/', $value] if ref($value) eq 'Regexp';
#   return ['!', $value] if ref($value) eq 'TestMLError';
#   return $value->{func} if ref($value) eq 'TestMLFunction';
#   return ['?', $value];
  end

  def uncook(value)

    type = self.type value

    return value if type.match /^(?:str|num|bool|null)$/;
    throw "hahaha"
#   return $value->[0] if $type =~ /^(?:list|hash)$/;
#   return $value->[1] if $type =~ /^(?:error|native)$/;
#   return TestMLFunction->new($value) if $type eq 'func';
#   if ($type eq 'regex') {
#     return ref($value->[1]) eq 'Regexp'
#     ? $value->[1]
#     : qr/${\ $value->[1]}/;
#   }
#   return () if $type eq 'none';

#   require XXX;
#   XXX::ZZZ("Can't uncook this value of type '$type':", $value);
  end

#------------------------------------------------------------------------------
  def get_method(pattern, *args)
    method = sprintf pattern, *(args.map {|a| self.type a})

    throw "Method '#{method}' does not exist" \
      unless self.respond_to?(method)

    return method
  end

  def get_label(label_expr)
    label_expr = '' unless defined? label_expr

    label = self.exec label_expr

#   $label ||= $self->getv('Label') || '';

    block_label = @block ? @block['label'] : ''

    if label
#     $label =~ s/^\+/$block_label/;
#     $label =~ s/\+$/$block_label/;
#     $label =~ s/\{\+\}/$block_label/;

    else
      label = block_label
      label = '' unless defined? label
    end

    return label
#   return $self->interpolate($label, true);
  end

# sub interpolate {
#   my ($self, $string, $label) = @_;
#   # XXX Hack to see input file in label:
#   $self->{vars}{File} = $ENV{TESTML_FILEVAR};

#   $string =~ s/\{([\-\w]+)\}/$self->transform1($1, $label)/ge;
#   $string =~ s/\{\*([\-\w]+)\}/$self->transform2($1, $label)/ge;

#   return $string;
# }

# sub transform {
#   my ($self, $value, $label) = @_;
#   my $type = $self->type($value);
#   if ($label) {
#     if ($type =~ /^(?:list|hash)$/) {
#       return encode_json($value->[0]);
#     }
#     if ($type eq 'regex') {
#       return "$value->[1]";
#     }
#     $value =~ s/\n/␤/g;
#     return "$value";
#   }
#   else {
#     if ($type =~ /^(?:list|hash)$/) {
#       return encode_json($value->[0]);
#     }
#     else {
#       return "$value";
#     }
#   }
# }

# sub transform1 {
#   my ($self, $name, $label) = @_;
#   my $value = $self->{vars}{$name};
#   return '' unless defined $value;
#   $self->transform($value, $label);
# }

# sub transform2 {
#   my ($self, $name, $label) = @_;
#   return '' unless $self->{block};
#   my $value = $self->{block}{point}{$name};
#   return '' unless defined $value;
#   $self->transform($value, $label);
# }

end

# vim: set sw=2 sts=2 et:
