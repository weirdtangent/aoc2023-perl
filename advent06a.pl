#!/usr/bin/perl

open(FH, "./input06");

my @times = <FH> =~ /(\d+)\s+/g;
my @dists = <FH> =~ /(\d+)\s+/g;
my $product = 1;

for (my $race=0; $race<@times; $race++) {
  my $win = 0;
  for (my $hold=0; $hold<$times[$race]; $hold++) {
    $win++ if $hold * ($times[$race]-$hold) > $dists[$race];
  }
  $product *= $win;
}

print $product."\n";
