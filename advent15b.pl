#!/usr/bin/perl

use strict;
use warnings;

my $h=0;
my $w='';
my $sum=0;
my @box;
while (my $data = <>) {
  my $label;
  my $op;
  my $fl;
  foreach my $c (split('', $data)) {
    if ($c !~ /[,\n]/) {
      $w .= $c;
      if ($c =~ /[a-z]/i) {
        $h += ord($c);
        $h *= 17;
        $h %= 256;
      }
    } else {
      ($label, $op, $fl) = $w =~ /(\w+)(.)(\d*)/;

      if ($op eq '=') {
        $box[$h] && $box[$h] =~ s/$label \d+/$label.' '.$fl/e or $box[$h] .= ",$label $fl";
      } else {
        $box[$h] && $box[$h] =~ s/,$label \d+//;
      }

      $w=''; $h = 0;
    }
  };
}

for (my $x=0; $x < 256; $x++) {
  next unless $box[$x];
  my $prod = 0;
  my $slot = 0;
  foreach my $lens (split(',', $box[$x])) {
    next if !$lens;
    my ($label, $fl) = split(' ', $lens);
    $slot++;
    $prod = ($x+1) * $slot * $fl;
    $sum += $prod;
  }
}
print "$sum\n";