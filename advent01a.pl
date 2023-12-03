#!/usr/bin/perl

my $sum = 0;
open(FH, "./input01");
while (<FH>) {
  chomp;
  my ($f) = /^\D*(\d)/;
  my ($l) = /(\d)\D*$/;
  $sum += ($f * 10 + $l) if $f && $l;
}
print $sum."\n";
