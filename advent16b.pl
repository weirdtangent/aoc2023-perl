#!/usr/bin/perl

use strict;
use warnings;

my $h=0;
my $w=0;
my $row=0;
my @map;
while (my $data = <>) {
  chomp $data;
  $w ||= length($data);
  push @{$map[$row++]}, split('', $data);
}
$h = $row;

my $sum = 0;
my $max = 0;
my $seen = {};
my $hit = {};

for (my $try = 0; $try < $w; $try++) {
  $seen = {}; $hit = {};
  my $pos = [ -1, $try];
  my $dir = [ 1, 0 ];
  trace($pos, $dir);
  $sum = scalar(keys %$hit);
  $max = $sum if $sum > $max;

  $seen = {}; $hit = {};
  $pos = [ $h, $try];
  $dir = [ -1, 0 ];
  trace($pos, $dir);
  $sum = scalar(keys %$hit);
  $max = $sum if $sum > $max;

  $seen = {}; $hit = {};
  $pos = [ $try, -1];
  $dir = [ 0, 1 ];
  trace($pos, $dir);
  $sum = scalar(keys %$hit);
  $max = $sum if $sum > $max;

  $seen = {}; $hit = {};
  $pos = [ $try, $w];
  $dir = [ 0, -1 ];
  trace($pos, $dir);
  $sum = scalar(keys %$hit);
  $max = $sum if $sum > $max;
}
print "$max\n";

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