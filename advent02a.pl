#!/usr/bin/perl

my $gameIds = 0;
my $max_red = 12;
my $max_green = 13;
my $max_blue = 14;

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

  $gameIds += $id unless $max{"red"} > $max_red || $max{"green"} > $max_green || $max{"blue"} > $max_blue;
}
print $gameIds."\n";
