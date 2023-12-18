#!/usr/bin/perl

use warnings;

my $r = 0;
my $c = 0;
my $p = 0;
my $dirs = { U => '-1,0', R => '0,1', D => '1,0', L => '0,-1'};
my @poly = ( [$r,$c] );

while (my $data = <>) {
  chomp $data;
  my ($dir, $dist) = $data =~ /^(\w) (\d+)/;

  my @d = split(',', $dirs->{$dir});
  $r += $d[0] * $dist;
  $c += $d[1] * $dist;
  $p += $dist;
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