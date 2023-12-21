#!/usr/bin/perl

use strict;
use warnings;

use List::MoreUtils qw/firstidx true/;

my $map;
my $r=0;
my $c=0;
my $h;
my $w;
my $posr;
my $posc;

while (my $data = <>) {
  chomp $data;
  push @{$map->[$r]}, split('', $data);
  $w //= length($data);
  if ((my $i = firstidx { $_ eq 'S' } @{$map->[$r]}) >= 0) {
    $posr = $r;
    $posc = $i;
  }
  $r++;
}
$h = $r;

my $dirs = [ [-1,0], [0,1], [1,0], [0,-1] ];
my %landed;
my $limit = 64;
print "$h x $w, starting at $posr,$posc for $limit\n";

process(1, $posr, $posc);

my $sum = true { /^$limit,/ } keys %landed;
print "$sum\n";

sub process {
  my ($m, $r, $c) = @_;

  foreach my $dir (@$dirs) {
    my $nr = $r+$dir->[0];
    my $nc = $c+$dir->[1];
    next if $nr < 0 || $nr >= $h;
    next if $nc < 0 || $nc >= $w;
    next if $map->[$nr][$nc] eq '#';
    next if exists $landed{"$m,$nr,$nc"};
    $landed{"$m,$nr,$nc"} = 1;
    process($m+1, $nr, $nc) if $m < $limit;
  }
}
