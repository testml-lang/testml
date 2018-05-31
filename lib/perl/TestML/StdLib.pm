use strict; use warnings;
package TestML::StdLib;

sub new {
  bless {}, shift;
}

sub cat {
  my ($self, @str) = @_;

  join '', @str;
}

sub false {
  require boolean;
  boolean::false();
}

my $json;
sub _json {
  require JSON::PP;
  $json ||= JSON::PP->new
    ->pretty
    ->indent_length(2)
    ->canonical(1)
    ->allow_nonref;
  return $json;
}

sub tojson {
  my ($self, $value) = @_;

  return $self->_json->encode($value);
}

sub fromjson {
  my ($self, $value) = @_;

  return $self->_json->decode($value);
}

sub true {
  require boolean;
  boolean::true();
}

1;
