#!/usr/bin/perl

=head2

with help/instruction from https://www.redblobgames.com/pathfinding/a-star/introduction.html
and some reddit hints/tips

=cut

use 5.30.0;
use warnings;

use List::PriorityQueue;

my $r = 0;
my $h;
my $w;
my %weight;

while (my $data = <>) {
  chomp $data;
  $w //= length($data)-1;
  my @data = split('', $data);
  for (my $c=0; $c<@data; $c++) {
    $weight{"$r,$c"} = $data[$c];
  }
  $r++;
}
$h = $r-1;
$weight{"0,0"} = 0;

print "map: $h x $w\n";

astar("0,0", "$h,$w");

sub astar {
  my ($start, $end) = @_;

  my $pq = new List::PriorityQueue;
  my @dirs = ('0,1', '1,0', '0,-1', '-1,0');
  my %cost;

  $pq->insert([$start,'START',0,'[0,0]'], 0);

  while (my $entry = $pq->pop()) {
    my ($current, $lastdir, $laststeps, $visited) = @$entry;

    # print "\n$visited\n";
    if ($current eq $end) {
      print "\nFINAL: $visited at cost ".$cost{"$current-$lastdir-$laststeps"}."\n";
      last;
    }

    foreach my $dir (@dirs) {
      next if $dir eq $lastdir;
      my $newvisit = '';
      my ($r1,$c1) = split(',', $current);
      my ($d1,$d2) = split(',', $dir);
      my ($r2,$c2) = ($r1,$c1);
      for (my $steps=1; $steps<=3; $steps++) {
        $r2 += $d1;
        $c2 += $d2;
        last if $r2 < 0 || $r2 > $h || $c2 < 0 || $c2 > $w; # can't go off the map

        my $next = "$r2,$c2";
        next if grep { /\[$next\]/ } split(' ', $visited);
        $newvisit .= ($newvisit ? ' ' : '') . "[$r2,$c2]"; # build list of individual steps

        my $new_cost = ($cost{"$current-$lastdir-$laststeps"}//0) + cost($current,$next);
        if (!exists $cost{"$next-$dir-$steps"} || $new_cost < $cost{"$next-$dir-$steps"}) {
          $cost{"$next-$dir-$steps"} = $new_cost;
          my $prio = $new_cost + heuristic($next, $end);
          # print "  checking $steps $dir to $next for cost $new_cost and priority $prio\n";
          $pq->insert([$next, $dir, $steps, $visited . ' ' . $newvisit], $prio);
        }
      }
    }
  }
}

sub cost {
  my ($current, $next) = @_;

  my $cost=0;

  my ($r1, $c1) = split(',', $current);
  my ($r2, $c2) = split(',', $next);

  if ($r1 eq $r2) {
    if ($c1 < $c2) {
      for (my $c=$c1+1; $c<=$c2; $c++) {
        $cost += $weight{"$r1,$c"};
      }
    } else {
      for (my $c=$c1-1; $c>=$c2; $c--) {
        $cost += $weight{"$r1,$c"};
      }
    }
  } elsif ($c1 eq $c2) {
    if ($r1 < $r2) {
      for (my $r=$r1+1; $r<=$r2; $r++) {
        $cost += $weight{"$r,$c1"};
      }
    } else {
      for (my $r=$r1-1; $r>=$r2; $r--) {
        $cost += $weight{"$r,$c1"};
      }
    }
  } else {
    die "moving from $current to $next is invalid?";
  }

  return $cost;
}

# Manhattan distance on a square grid
sub heuristic {
  my ($a, $b) = @_;

  my ($r1, $c1) = split(',', $a);
  my ($r2, $c2) = split(',', $b);
  return abs($r2 - $r1) + abs($c2 - $c1);
}