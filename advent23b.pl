#!/usr/bin/perl

use strict;
use warnings;
no warnings 'recursion';

use List::Util qw/any max/;
use Storable qw/dclone/;

my $map;
my $r=0;
my $c=0;
my $h;
my $w;

while (my $data = <>) {
  chomp $data;
  $data =~ s/[^\.#]/./g;
  push @{$map->[$r++]}, split('', $data);
  $w //= length($data)-1;
}
$h = $r-1;

# starting position
my $sr = 0;
my $sc = 1;
my $er = $h;
my $ec = $w-1;

print "map: $h x $w\n";
print "starting at $sr,$sc and trying to get to $er,$ec\n\n";

my %dirs = ( N => [-1,0], E => [0,1], S => [1,0], W => [0,-1] );

my $longest=0;
follow($sr, $sc, 0, 0, 0, ());

print "$longest\n";

sub follow {
  my ($r, $c, $pr, $pc, $length, %visited) = @_;

  while (1) {
    $visited{"$r,$c"} = 1;
    
    # found END, remember steps for longest path
    if ($r == $er && $c == $ec) {
      $longest = max($length, $longest);
      print "longest so far: $longest\n" if $longest == $length;
      return 1;
    }

    # we really only need to recurse if there are multiple choices to go 
    my @choices;
    my $possible=0;
    foreach my $dir (keys %dirs) {
      my $nr = $r + $dirs{$dir}->[0];
      my $nc = $c + $dirs{$dir}->[1];

      next if $map->[$nr][$nc] eq '#';         # a wall, which also keeps us from going off the map!
      $possible++ if $nr != $pr || $nc != $pc; # a possible choice if it is not where we just came from
      next if exists $visited{"$nr,$nc"};      # already been there

      push @choices, { r => $nr, c => $nc, d => $dir};
    }

    # if zero choices of where to go, return to last decision point
    # but return how many places we MIGHT have gone, if we hadn't already visited them
    # if we REALLY hit a dead end - we'll get 0 possible
    return if !@choices;

    # if multiple choices of where we can go, recurse on each one, and then return
    if (@choices > 1) {
      foreach my $ch (@choices) {
        my ($cr, $cc, $dir) = ($ch->{r}, $ch->{c}, $ch->{d});
        follow($cr, $cc, $r, $c, $length+1, %visited);
      }
      return;
    }

    # just one choice, so just do it without recursion
    # but we need to set the NEW prior r,c and current r,c
    ($pr, $pc, $r, $c) = ($r, $c, $choices[0]->{r}, $choices[0]->{c});
    $length++;
  }
}