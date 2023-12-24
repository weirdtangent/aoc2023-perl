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
follow($sr, $sc, 0, ());

print "$longest\n";

sub follow {
  my ($r, $c, $length, %visited) = @_;

  $visited{"$r,$c"} = 1;

  # found END, remember steps for longest path
  if ($r == $er && $c == $ec) {
    $longest = max($length, $longest);
    return;
  }

  foreach my $dir (keys %dirs) {
    # if current pos is an arrow we must obey it
    next if $map->[$r][$c] eq 'v' && $dir ne 'S';
    next if $map->[$r][$c] eq '^' && $dir ne 'N';
    next if $map->[$r][$c] eq '<' && $dir ne 'W';
    next if $map->[$r][$c] eq '>' && $dir ne 'E';

    my $nr = $r + $dirs{$dir}->[0];
    my $nc = $c + $dirs{$dir}->[1];

    next if $map->[$nr][$nc] eq '#';    # a wall, which also keeps us from going off the map
    next if exists $visited{"$nr,$nc"}; # already been there

    # if the next pos is an arrow we can't enter from the dir it points to
    next if $map->[$nr][$nc] eq 'v' && $dir ne 'S';
    next if $map->[$nr][$nc] eq '^' && $dir ne 'N';
    next if $map->[$nr][$nc] eq '<' && $dir ne 'W';
    next if $map->[$nr][$nc] eq '>' && $dir ne 'E';

    follow($nr, $nc, $length+1, %visited);
  }
  return;
}