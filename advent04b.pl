#!/usr/bin/perl

my $sum = 0;
my @winning;
my @mine;

open(FH, "./input04");
while (<FH>) {
  chomp;
  my ($card, $winners, $mynums) = /Card\s+(\d+): (.*?) \| (.*)/;
  next unless $card;
  push @winning, $winners;
  push @mine, $mynums;
}

for (my $x=0; $x<scalar @winning; $x++) {
  my $card = $x+1;
  my $matched = 0;
  my %winningnums = map { $_ => 1 } split(' ', $winning[$x]);
  foreach my $num (split(' ', $mine[$x])) {
    next unless exists $winningnums{$num};
    $matched++;
  }
  my $totalcards = exists $extra{$card} ? $extra{$card} + 1 : 1;
  $sum += $totalcards;
  my $nextcard = $card;
  while ($matched) {
    $nextcard++;
    $extra{$nextcard}+=$totalcards;
    $matched--;
  }
}

print $sum."\n";
