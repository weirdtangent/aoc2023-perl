#!/usr/bin/perl

use strict;
use warnings;

my $h=0;
my $w='';
my $sum=0;
while (my $data = <>) {
  foreach my $c (split('', $data)) {
    $sum += $h, $w='', $h = 0, next if $c =~ /[,\n]/;
    $w .= $c;
    $h += ord($c);
    $h *= 17;
    $h %= 256;
  };
}
print "$sum\n";