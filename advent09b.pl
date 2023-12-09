#!/usr/bin/perl

my @data;
my $sum = 0;

open(FH, "./input09");
while (<FH>) {
  chomp;
  $sum+=predictback(split(' ', $_));
}
print $sum."\n";


sub predictback () {
  my @data = @_;

  my $level = 0;
  my $nonzero = 1;
  my %next;
  $next{$level} = \@data;

  while ($nonzero) {
    $level++;
    $nonzero = 0;
    for (my $x=0; $x<@{$next{$level-1}}-1; $x++) {
      my $diff = $next{$level-1}->[$x+1] - $next{$level-1}->[$x];
      $nonzero++ if $diff;
      push @{$next{$level}}, $diff;
    }
  };
  unshift @{$next{$level}}, 0;

  for (my $x=$level-1; $x>=0; $x--) {
    unshift @{$next{$x}}, $next{$x}->[0] - $next{$x+1}->[0];
  }
  return $next{0}->[0];
}