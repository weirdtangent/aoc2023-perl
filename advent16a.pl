#!/usr/bin/perl

use strict;
use warnings;

my $h = 0;
my $w = 0;
my $sum = 0;
my $row = 0;
my @map;
while (my $data = <>) {
  chomp $data;
  $w ||= length($data);
  push @{$map[$row++]}, split('', $data);
}
$h = $row;

my $seen = {};
my $hit = {};
my $pos = [ 0, -1 ];
my $dir = [ 0,  1 ];

trace($pos, $dir);
$sum = scalar(keys %$hit);
print "$sum\n";

sub trace {
  my ($pos, $dir) = @_;

  while(1) {
    $pos->[0] += $dir->[0];
    $pos->[1] += $dir->[1];
    return if $pos->[0] < 0 || $pos->[0] >= $w || $pos->[1] < 0 || $pos->[1] >= $h; # off map

    return if exists $seen->{"@$pos @$dir"}; # been here: in loop
    $hit->{"@$pos"}=1;
    $seen->{"@$pos @$dir"}++;

    my $space = $map[$pos->[0]][$pos->[1]];
    if ($space eq '/')                 { @$dir = ( $dir->[1] * -1, $dir->[0] * -1 ); }
    elsif ($space eq '\\')             { @$dir = ( $dir->[1], $dir->[0] ); }
    elsif ($space eq '-' && $dir->[0]) { @$dir = (  0, -1 ); my $new = [ @$pos ]; trace($new, [ 0, 1 ]); }
    elsif ($space eq '|' && $dir->[1]) { @$dir = ( -1,  0 ); my $new = [ @$pos ]; trace($new, [ 1, 0 ]); }
  }
}