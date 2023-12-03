#!/usr/bin/perl

my $powers = 0;

open(FH, "./input02");
while (<FH>) {
  chomp;
  next unless /^Game/;

  my ($id, $pulls) = $_ =~ /Game (\d+): (.*)/;
  my %max;
  foreach my $pull (split(';',$pulls)) {
    foreach my $cube (split(',',$pull)) {
      my ($count,$color) = $cube =~ /(\d+) (\w+)/;
      $max{$color} = $count if !exists $max{$color} or $count > $max{$color};
    }
  }

  $powers += $max{"red"} * $max{"green"} * $max{"blue"};
}
print $powers."\n";
