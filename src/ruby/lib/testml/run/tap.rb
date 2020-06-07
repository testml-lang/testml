require 'testml/run'

class TestML::Run::TAP < TestML::Run
  def self.run(file)
    TestML::Run::TAP.new.from_file(file).test;
  end

  def initialize(params={})
    @count = 0
    super
#   my $self = $class->SUPER::new(@params);
# 
#   return $self;
    return self
  end

  def testml_begin
    @checked = false
    @planned = false
  end

  def testml_end
    self.tap_done \
      unless @planned
  end

  def testml_eq(got, want, label, not_=false)
    self.check_plan

    self.tap_is got, want, label
  end
#   if (not $not and
#       $got ne $want and
#       $want =~ /\n/ and
#       (not defined $self->getv('Diff') or $self->getv('Diff')) and
#       not($ENV{TESTML_NO_DIFF})
#   ) {
#     require Text::Diff;
# 
#     $self->tap_ok(0, $label ? ($label) : ());
# 
#     my $diff = Text::Diff::diff(
#       \$want,
#       \$got,
#       {
#         FILENAME_A => 'want',
#         FILENAME_B => 'got',
#       }
#     );
# 
#     $self->tap_diag($diff);
#   }
#   elsif ($not) {
#     $self->tap_isnt($got, $want, $label ? ($label) : ());
#   }
#   else {
#     $self->tap_is($got, $want, $label ? ($label) : ());
#   }
# }
# 
# sub testml_like {
#   my ($self, $got, $want, $label, $not) = @_;
#   $self->check_plan;
# 
#   if ($not) {
#     $self->tap_unlike($got, $want, $label);
#   }
#   else {
#     $self->tap_like($got, $want, $label);
#   }
# }
# 
# sub testml_has {
#   my ($self, $got, $want, $label, $not) = @_;
#   $self->check_plan;
# 
#   my $index = index($got, $want);
#   if ($not ? ($index == -1) : ($index != -1)) {
#     $self->tap_ok(1, $label);
#   }
#   else {
#     $self->tap_ok(0, $label);
#     my $verb = $not ? '   does' : "doesn't";
#     $self->tap_diag("     this string: '$got'\n $verb contain: '$want'");
#   }
# }
# 
# sub testml_list_has {
#   my ($self, $got, $want, $label) = @_;
#   $self->check_plan;
# 
#   for my $str (@$got) {
#     next if ref $str;
#     if ($str eq $want) {
#       $self->tap_ok(1, $label);
#       return;
#     }
#   }
#   $self->tap_ok(0, $label);
#   $self->tap_diag("     this list: @$got\n  doesn't contain: $want");
# }
# 
  def check_plan
    return if @checked
    @checked = true
  end

# sub check_plan {
#   my ($self) = @_;
# 
#   return if $self->{checked};
#   $self->{checked} = 1;
# 
#   if (my $plan = $self->{vars}{Plan}) {
#     $self->{planned} = 1;
#     $self->tap_plan($plan);
#   }
# }
# 
# sub tap_plan {
#   my ($self, $plan) = @_;
#   $self->out("1..$plan");
# }

  def tap_pass(label='')
    label = " - #{label}" if label != '';
    @count += 1
    self.out "ok #{@count}#{label}"
    return
  end

  def tap_fail(label='')
    label = " - #{label}" if label != '';
    @count += 1
    self.out "not ok #{@count}#{label}"
  end

  def tap_ok(ok, label)
    if ok
      self.tap_pass label
    else
      self.tap_fail label
    end
  end

  def tap_is(got, want, label)
    ok = got == want
    if ok
      self.tap_pass label
    else
      self.tap_fail label
    end
  end
#     $self->show_error(
#       '         got:', $got,
#       '    expected:', $want,
#       $label,
#     );
#   }
# }
# 
# sub tap_isnt {
#   my ($self, $got, $want, $label) = @_;
#   my $ok = $got ne $want;
#   if ($ok) {
#     $self->tap_pass($label);
#   }
#   else {
#     $self->tap_fail($label);
#     $self->show_error(
#       '         got:', $got,
#       '    expected:', 'anything else',
#       $label,
#     );
#   }
# }
# 
# sub tap_like {
#   my ($self, $got, $want, $label) = @_;
#   if ($got =~ $want) {
#     $self->tap_pass($label);
#   }
#   else {
#     $self->tap_fail($label);
#   }
# }
# 
# sub tap_unlike {
#   my ($self, $got, $want, $label) = @_;
#   if ($got !~ $want) {
#     $self->tap_pass($label);
#   }
#   else {
#     $self->tap_fail($label);
#   }
# }
# 
# sub tap_diag {
#   my ($self, $msg) = @_;
#   my $str = $msg;
#   $str =~ s/^/# /mg;
#   $self->err($str);
# }

  def tap_done
    self.out "1..#{@count}"
  end

# sub show_error {
#   my ($self, $got_prefix, $got, $want_prefix, $want, $label) = @_;
#   if ($label) {
#     $self->err("#   Failed test '$label'");
#   }
#   else {
#     $self->err("#   Failed test");
#   }
# 
#   if (not ref $got) {
#     $got = "'$got'"
#   }
#   $self->tap_diag("$got_prefix $got");
# 
#   if (not ref $want) {
#     $want = "'$want'"
#   }
#   $self->tap_diag("$want_prefix $want");
# }

  def out(str)
    # TODO
#   local $| = 1;
#   binmode STDOUT, ':utf8';
    puts str
  end

  def err(str)
    $stderr.puts str
  end
end

# vim: set sw=2 sts=2 et:
