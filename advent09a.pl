#!/usr/bin/perl

my @data;
my $sum = 0;

open(FH, "./input09");
while (<FH>) {
  chomp;
  $sum+=predict(split(' ', $_));
}
print "$sum\n";


sub predict () {
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
  push @{$next{$level}}, 0;

  for (my $x=$level-1; $x>=0; $x--) {
    push @{$next{$x}}, $next{$x}->[-1] + $next{$x+1}->[-1];
  }
  return $next{0}->[-1];
}