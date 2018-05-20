use strict; use warnings;
package TestML::StdLib;

sub new {
  bless {}, shift;
}

sub true {
  require boolean;
  boolean::true();
}

sub false {
  require boolean;
  boolean::false();
}

1;

# vim: ft=perl sw=2:
