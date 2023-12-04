#!/usr/bin/perl

my $sum = 0;
open(FH, "./input04");
while (<FH>) {
  chomp;
  my ($card, $winning, $mine) = /Card\s+(\d+): (.*?) \| (.*)/;
  next unless $card;
  my %winning = map { $_ => 1 } split(' ', $winning);
  my $wintotal = 0;
  foreach my $num (split(' ', $mine)) {
    next unless exists $winning{$num};
    $wintotal = $wintotal ? $wintotal * 2 : 1;
  }
  $sum += $wintotal;
}

print $sum."\n";
