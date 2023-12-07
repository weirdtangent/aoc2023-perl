#!/usr/bin/perl

use List::Util qw(any);

my $facecard = { 'A' => 14, 'K' => 13, 'Q' => 12, 'J' => 11, 'T' => 10 };
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

  my @eachcard = split('', $hand);
  foreach (@eachcard) {
    $card{$_}++;
  }
  my $cards = scalar(keys %card);

  my $score = 0;

  if ($cards == 1) {
    $score += 700;
  } elsif (any { $card{$_} == 4 } keys %card) {
    $score += 600;
  } elsif ((any { $card{$_} == 3 } keys %card) && (any { $card{$_} == 2 } keys %card)) {
    $score += 500;
  } elsif (any { $card{$_} == 3 } keys %card) {
    $score += 400;
  } elsif ((any { $card{$_} == 2 } keys %card) && $cards == 3) {
    $score += 300;
  } elsif (any { $card{$_} == 2 } keys %card) {
    $score += 200;
  }

  $score = sprintf("%03d", $score);
  $score .= " ".join(' ', map { exists $facecard->{$_} ? $facecard->{$_} : "0".$_ } @eachcard);
  return $score;
}
