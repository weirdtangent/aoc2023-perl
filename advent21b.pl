#!/usr/bin/perl

=head2

I knew I couldn't brute-force the answer, BUT I expected that once I solved one
full "map" then I could extrapolate that across "any number of the same full maps
PLUS add the partial maps (if any)" - but that's where I got lost after 4 hours...

I got lots and lots of hints from:

https://www.reddit.com/r/adventofcode/comments/18nevo3/comment/keaidqr/?utm_source=share&utm_medium=web2x&context=3

which ended up showing my loop was working (though, not so fast - it takes ~30s to
run for 327). I just needed to use my results in a "quadratic fit calculator" to get
the quadatric equationfor my input, and then I could solve for my "x"

And then, I learned from:

https://www.reddit.com/r/adventofcode/comments/18nevo3/comment/keays65/?utm_source=share&utm_medium=web2x&context=3
and
https://www.reddit.com/r/adventofcode/comments/18nevo3/comment/keb8ud3/?utm_source=share&utm_medium=web2x&context=3
and
https://www.geeksforgeeks.org/lagrange-interpolation-formula/

how to turn my 3 (x,y) pairs [which end up being (327,q1); (196,q2); and (65,q3)] into
a quadratic equation myself with something called "Lagrange's Interpolation formula"

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

my $q3 = true { /^$climit,/ } keys %landed;
my $q2 = true { /^$blimit,/ } keys %landed;
my $q1 = true { /^$alimit,/ } keys %landed;
# print "$q1, $q2, and $q3\ncalculate the quatric fit from those (see link) and then use the resulting quadratic formula to solve for x=$qx:\n";
# print "https://www.wolframalpha.com/input?i=quadratic+fit+calculator&assumption=%7B%22F%22%2C+%22QuadraticFitCalculator%22%2C+%22data%22%7D+-%3E%22%7B$qc%2C+$qb%2C+$qa%7D%22\n";

# Lagrange's Interpolation formula for ax^2 + bx + c with x=[0,1,2] and y=[y0,y1,y2] we have
#   f(x) = (x^2-3x+2) * y0/2 - (x^2-2x)*y1 + (x^2-x) * y2/2
# so the coefficients are:
# a = y0/2 - y1 + y2/2       (or (y0 - 2*y1 + y2)/2) )
# b = -3*y0/2 + 2*y1 - y2/2 ( or (-3*y0 + 4*y1 - y2)/2) )
# c = y0
#
# my y0 is $q3, y1 is $q2, y2 is $q1, so:
my $qa = ($q3 - 2*$q2 + $q1) / 2;
my $qb = (-3*$q3 + 4*$q2 - $q1) / 2;
my $qc = $q3;

print "\nwe find: $qa x^2 + $qb x + $qc, x = $qx\n";

my $result = $qa * $qx ** 2 + $qb * $qx + $qc;
print "$result\n";


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