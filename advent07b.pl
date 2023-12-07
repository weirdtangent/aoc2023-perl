#!/usr/bin/perl

use List::Util qw(any);

my $facecard = { 'A' => 14, 'K' => 13, 'Q' => 12, 'J' => 11, 'T' => 10, 'J' => 1 };
my %hands;
my %scores;
push @list;
push @bids;

my $sum = 0;
open(FH, "./input07");
while (<FH>) {
  chomp;
  my ($hand, $bid) = split(' ', $_);
  $hands{$hand} = $bid;
}

foreach (keys %hands) {
  my $score = score($_);
  $scores{$_} = $score;
};

my $sum = 0;
my $rank = 0;
foreach (sort { $scores{$a} cmp $scores{$b} } keys %scores) {
  $rank++;
  $sum += $hands{$_} * $rank;
}

print $sum."\n";

sub score() {
  my ($hand) = @_;

  my %card;
  my $fives;
  my $fours;
  my $threes;
  my $twos;

  my @eachcard = split('', $hand);
  foreach (@eachcard) {
    $card{$_}++;
  }
  foreach (keys %card) {
    next if /J/;
    $fives++  if $card{$_} == 5;
    $fours++  if $card{$_} == 4;
    $threes++ if $card{$_} == 3;
    $twos++   if $card{$_} == 2;
  }
  my $cards = scalar(keys %card);
  $card{'J'}=0 if not exists $card{'J'};

  my $score = 0;

  if ($fives || $card{'J'} == 5) {
    $score = 700;
  } elsif (any { $_ ne 'J' && $card{$_} + $card{'J'} == 5 } keys %card) {
    $score = 700;
  } elsif ($fours) {
    $score = 600;
  } elsif (any { $_ ne 'J' && $card{$_} + $card{'J'} == 4 } keys %card) {
    $score = 600;
  } elsif ($threes && $twos) {
    $score = 500;
  } elsif ($twos == 2 && $card{'J'} == 1) {
    $score = 500;
  } elsif ($threes) {
    $score = 400;
  } elsif (any { $_ ne 'J' && $card{$_} + $card{'J'} == 3} keys %card) {
    $score = 400;
  } elsif ($twos > 1) {
    $score = 300;
  } elsif ($twos && $card{'J'} == 1) {
    $score = 300;
  } elsif ($card{'J'} == 1) {
    $score = 200;
  } elsif (any { $card{$_} == 2} keys %card) {
    $score = 200;
  }

  $score = sprintf("%03d", $score);
  $score .= " ".join(' ', map { sprintf("%02d", exists $facecard->{$_} ? $facecard->{$_} : $_) } @eachcard);
  return $score;
}
