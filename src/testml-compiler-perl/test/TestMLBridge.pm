use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

use File::Temp qw/tempdir/;
use Capture::Tiny 'capture';

sub undent {
  my ($self, $text) = @_;
  $text =~ s/^    //mg;
  return $text;
}

sub compile {
  my ($self, $testml, $import) = @_;
  $import = $self->parse_import($import);

  my ($temp_dir) = tempdir or die;
  my $temp_file = "$temp_dir/test.tml";
  open my $temp_handle, '>', $temp_file
    or die "Can't open '$temp_file' for output: $!";
  print $temp_handle $testml;
  close $temp_handle;

  for my $file (keys %$import) {
    my $temp_file = "$temp_dir/$file";
    open my $temp_handle, '>', $temp_file
      or die "Can't open '$temp_file' for output: $!";
    print $temp_handle $import->{$file};
    close $temp_handle;
  }

  my ($stdout, $stderr, $rc) = capture {
    system("testml-compiler $temp_file");
  };

  die "Error while testing testml-compiler:\n$stderr"
    if $rc != 0;

  warn $stderr if $stderr;

  return $stdout;
}

sub parse_import {
  my ($self, $import) = @_;

  return {} unless $import;

  my @import = split /^\+\+\+\ (.*)\n/m, $import;
  shift @import;

  return {@import};
}

1;
