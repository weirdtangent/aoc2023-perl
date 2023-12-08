#!/usr/bin/perl

use List::Util qw(max);

$| = 1;

open(FH, "./input08");
my $dir = <FH>;
chomp $dir;
<FH>;

$dir =~ s/L/0/g;
$dir =~ s/R/1/g;

my @paths;
while (my $data = <FH>) {
  chomp $data;
  my ($code, $left, $right) = $data =~ /(\w+) = \((\w+), (\w+)\)/;
  push @{$base{$code}}, $left;
  push @{$base{$code}}, $right;
  if ($code =~ /A$/) {
    push @paths, $code;
  }
}

my @moves = split('', $dir);
my $maxmoves = scalar @moves;

my $move = 0;
my $steps = 0;
my $go;
my @sol;
for (my $x=0; $x<@paths; $x++) {
  $move = 0;
  $steps = 0;
  while (1) {
    $paths[$x] = $base{$paths[$x]}->[$moves[$move++]];
    $move %= $maxmoves;
    $steps++;
    last if substr($paths[$x],-1) eq 'Z'
  }
  push @sol, $steps;
}

print lcm($sol[0], lcm($sol[1], lcm($sol[2], lcm($sol[3], lcm($sol[4], $sol[5])))))."\n";

sub lcm() {
  my ($n1, $n2) = @_;

  my $highest = max($n1, $n2);
  my $lcm = $highest;
  while (1) {
    if ($lcm % $n1 == 0 && $lcm % $n2 == 0) {
      return $lcm;
    }
    $lcm += $highest;
  }
}