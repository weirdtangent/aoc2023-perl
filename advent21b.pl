#!/usr/bin/perl

=head2

I knew I couldn't brute-force the answer, and I expected that once I solved one "map"
then I could extrpolate that same answer for "any number of the same full maps PLUS
the partial maps (if any)" - but that's where I got lost:

I got lots and lots of help from:

https://www.reddit.com/r/adventofcode/comments/18nevo3/comment/keaidqr/?utm_source=share&utm_medium=web2x&context=3

which ended up showing my loop was working - I just needed a "quadratic fit calculator"
to get the quadatric equation and then I could solve for my "x"

=cut

$| = 1;

use strict;
use warnings;
no warnings 'recursion';

use List::MoreUtils qw/firstidx true/;

my $map;
my $r=0;
my $c=0;
my $h;
my $w;
my $posr;
my $posc;

while (my $data = <>) {
  chomp $data;
  push @{$map->[$r]}, split('', $data);
  $w //= length($data);
  if ((my $i = firstidx { $_ eq 'S' } @{$map->[$r]}) >= 0) {
    $posr = $r;
    $posc = $i;
  }
  $r++;
}
$h = $r;

my $dirs = [ [-1,0], [0,1], [1,0], [0,-1] ];
my %landed;

my $limit = 26501365;
my $qx = ($limit - $posr) / $w;

# answer is quadratic (ax^2 + bx +c), so we can get:
#  c = count after "pos" on map, since it is in the center
#  b = count after "pos" + "width" (or "height" since it is square)
#  a = count after "pos" + "2 x width"
# 
# and then use those 3 points to "fit" into a quadratic equation (thanks WA)
# and use that equation to solve where x = ((our BIG limit - "pos") / "width")
my $alimit = $posr + (2 * $w);
my $blimit = $posr + (1 * $w);
my $climit = $posr;

# global var that process() checks - do alimit instead of that giant number
$limit = $alimit;

print "$h x $w, starting at $posr,$posc for $alimit (and $blimit and $climit)\n\n";
process(1, $posr, $posc);

my $qc = true { /^$climit,/ } keys %landed;
my $qb = true { /^$blimit,/ } keys %landed;
my $qa = true { /^$alimit,/ } keys %landed;
print "$qa, $qb, and $qc\ncalculate the quatric fit from those (see link) and then use the resulting quadratic formula to solve for x=$qx:\n";
print "https://www.wolframalpha.com/input?i=quadratic+fit+calculator&assumption=%7B%22F%22%2C+%22QuadraticFitCalculator%22%2C+%22data%22%7D+-%3E%22%7B$qc%2C+$qb%2C+$qa%7D%22\n";


sub process {
  my ($m, $r, $c) = @_;

  foreach my $dir (@$dirs) {
    my ($nr, $nc) = ($r + $dir->[0], $c + $dir->[1]);

    my ($enr, $enc) = ($nr % $w, $nc % $h);
    next if $map->[$enr][$enc] eq '#';

    next if exists $landed{"$m,$nr,$nc"};
    $landed{"$m,$nr,$nc"} = 1;

    process($m+1, $nr, $nc) if $m < $limit;
  }
}