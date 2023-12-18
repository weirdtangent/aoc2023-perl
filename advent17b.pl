#!/usr/bin/perl

=head2

with help/instruction from https://www.redblobgames.com/pathfinding/a-star/introduction.html

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
  my %tried;

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
      my $newcost = 0;
      my ($r1,$c1) = split(',', $current);
      my ($d1,$d2) = split(',', $dir);
      my ($r2,$c2) = ($r1,$c1);
      for (my $steps=1; $steps<=10; $steps++) {
        $r2 += $d1;
        $c2 += $d2;
        last if $r2 < 0 || $r2 > $h || $c2 < 0 || $c2 > $w; # can't go off the map

        my $next = "$r2,$c2";
        last if grep { /\[$next\]/ } split(' ', $visited);
        $newvisit .= ($newvisit ? ' ' : '') . "[$r2,$c2]"; # build list of individual steps
        $newcost += $weight{$next};

        next if $steps < 4; # we need to do each step, but none can be tested except 4-10
        next if $tried{"$next-$dir-$steps"};

        my $total_cost = ($cost{"$current-$lastdir-$laststeps"}//0) + $newcost;
        if (!exists $cost{"$next-$dir-$steps"} || $total_cost < $cost{"$next-$dir-$steps"}) {
          $tried{"$next-$dir-$steps"} = 1;
          $cost{"$next-$dir-$steps"} = $total_cost;
          my $prio = $total_cost + heuristic($next, $end);
          # print "  checking $steps $dir to $next for cost $total_cost and priority $prio\n";
          $pq->insert([$next, $dir, $steps, $visited . ' ' . $newvisit], $prio);
        }
      }
    }
  }
}

# Manhattan distance on a square grid
sub heuristic {
  my ($a, $b) = @_;

  my ($r1, $c1) = split(',', $a);
  my ($r2, $c2) = split(',', $b);
  return abs($r2 - $r1) + abs($c2 - $c1);
}