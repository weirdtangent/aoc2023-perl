#!/usr/bin/perl

open(FH, "./input06");

my $time_data = <FH>;
$time_data =~ s/\D//g;

my $dist_data = <FH>;
$dist_data =~ s/\D//g;

my $win = 0;
for (my $hold=0; $hold<$time_data; $hold++) {
  $win++ if $hold * ($time_data-$hold) > $dist_data;
}

print $win."\n";
