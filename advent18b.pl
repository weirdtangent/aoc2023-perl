#!/usr/bin/perl

use warnings;

my $r = 0;
my $c = 0;
my $p = 0;
my $dirs = { 0 => '0,1', 1 => '1,0', 2 => '0,-1', 3 => '-1,0' };
my @poly = ( [$r,$c] );

while (my $data = <>) {
  chomp $data;
  my ($hex, $d) = $data =~ /\(\#([0-9a-f]{5})(\d)\)/i;

  my $dist = hex("0x$hex");
  $p += $dist;
  my @d = split(',', $dirs->{$d});
  $r += $d[0] * $dist;
  $c += $d[1] * $dist;
  push @poly, [$r,$c];
}

print ((area_by_shoelace(@poly) + int($p/2) + 1)."\n");

# Shoelace formula from https://rosettacode.org/wiki/Shoelace_formula_for_polygonal_area#Perl
sub area_by_shoelace {
    my (@p) = @_;

    my $area;
    $area += $p[$_][0] * $p[($_+1)%@p][1] for 0 .. @p-1;
    $area -= $p[$_][1] * $p[($_+1)%@p][0] for 0 .. @p-1;

    return int(abs($area/2));
}