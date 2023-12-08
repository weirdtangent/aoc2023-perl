#!/usr/bin/perl

open(FH, "./input08");
my $dir = <FH>;
chomp $dir;
<FH>;

$dir =~ s/L/0/g;
$dir =~ s/R/1/g;

while (my $data = <FH>) {
  chomp $data;
  my ($code, $left, $right) = $data =~ /(\w+) = \((\w+), (\w+)\)/;
  push @{$base{$code}}, $left;
  push @{$base{$code}}, $right;
}

my @moves = split('', $dir);
my $move = 0;
my $steps = 0;
my $pos = "AAA";
while ($pos ne "ZZZ") {
  $pos = $base{$pos}->[$moves[$move++]];
  $move %= @moves;
  $steps++;
}

print $steps."\n";
