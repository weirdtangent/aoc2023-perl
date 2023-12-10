#!/usr/bin/perl

use List::Util qw/max/;
use List::MoreUtils qw/first_index/;
use Data::Dumper;

my $map;
my $posR;
my $posC;
my $seen;

my $dir = {
  '|' => { b => [-1, 0], f => [ 1, 0] },
  '-' => { b => [ 0,-1], f => [ 0, 1] },
  'L' => { b => [-1, 0], f => [ 0, 1] },
  'J' => { b => [ 0,-1], f => [-1, 0] },
  '7' => { b => [ 0,-1], f => [ 1, 0] },
  'F' => { b => [ 0, 1], f => [ 1, 0] },
};

open(FH, "./input10");
my $r=0;
while (my $data = <FH>) {
  chomp $data;
  my @cols = split '', $data;
  my $c = first_index { $_ eq 'S' } @cols;
  if ($c >= 0) { $posR = $r; $posC = $c; }
  push @{$map->[$r++]}, @cols;
}

my $maxF = 0;
my $maxB = 0;
my $fR = $posR;
my $fC = $posC;
my $bR = $posR;
my $bC = $posC;
my $noF;
my $noB;

$map->[$posR][$posC] = 'J'; # manually "fix" map
$seen->{"$posR,$posC"}++;

# keep going while we are able to go FWD or BCK
while (!$noF || !$noB) {
  my $fmap = $map->[$fR][$fC];
  my $bmap = $map->[$bR][$bC];

  # if we can go fwd or bck
  if (!exists $seen->{($fR + $dir->{$fmap}->{f}->[0]).",".($fC + $dir->{$fmap}->{f}->[1])} || !exists $seen->{($fR + $dir->{$fmap}->{b}->[0]).",".($fC + $dir->{$fmap}->{b}->[1])}) {
    # choose which way we haven't gone yet
    my $fdir = (exists $seen->{($fR + $dir->{$fmap}->{f}->[0]).",".($fC + $dir->{$fmap}->{f}->[1])}) ? 'b' : 'f';
    $fR += $dir->{$fmap}->{$fdir}->[0];
    $fC += $dir->{$fmap}->{$fdir}->[1];
    $seen->{"$fR,$fC"} = 1;
    $maxF++;
  } else { $noF = 1; }

  # if we can go fwd or bck
  if (!exists $seen->{($bR + $dir->{$bmap}->{f}->[0]).",".($bC + $dir->{$bmap}->{f}->[1])} || !exists $seen->{($bR + $dir->{$bmap}->{b}->[0]).",".($bC + $dir->{$bmap}->{b}->[1])}) {
    # choose which way we haven't gone yet
    my $bdir = (exists $seen->{($bR + $dir->{$bmap}->{b}->[0]).",".($bC + $dir->{$bmap}->{b}->[1])}) ? 'f' : 'b';
    $bR += $dir->{$bmap}->{$bdir}->[0];
    $bC += $dir->{$bmap}->{$bdir}->[1];
    $seen->{"$bR,$bC"} = 1;
    $maxB++;
  } else { $noB = 1; }
}

print max($maxF, $maxB)."\n";