#!/usr/bin/perl

use strict;
use warnings;

use List::Util qw/any/;

$| = 1;

my $row = 0;
my $sum = 0;
my $count = 0;
my %memo;

open(FH, "./input12test2");
while (my $data = <FH>) {
  chomp $data;
  $row++;

  my ($string, $groups) = $data =~ /^(\S+) (\S+)/;
  $string = "$string?$string?$string?$string?$string";
  $groups = "$groups,$groups,$groups,$groups,$groups";

  $count = solve($string, $groups, 0);
  print "$row = $count\n";
  $sum += $count;
  undef %memo;
}
print "$sum\n";

sub solve {
  my ($string, $groups, $i) = @_;

  my $result = 0;
  my @string = split('', $string);
  my @groups = split(',', $groups);
  my $lastpos = length($string)-1;

  if (!@groups) {
    return (any { /\#/ } @string[$i..$lastpos]) ? 0 : 1;
  }

  return 0 if $i >= $lastpos;
  while ($string[$i] ne '?' && $string[$i] ne '#') {
    $i++;
    return 0 if $i >= $lastpos;
  }

  my $key = "$i ".scalar(@groups);
  return $memo{$key} if exists $memo{$key};

  if (join('', @string[$i..$lastpos]) =~ /^[\?\#]{$groups[0]}/) {
    $result += solve($string, join(',', @groups[1..@groups-1]), $i + $groups[0] + 1);
  }

  if ($string[$i] eq '?') {
    $result += solve($string, $groups, $i + 1);
  }

  $memo{$key} = $result;
  return $result;
}

#
# https://www.reddit.com/r/adventofcode/comments/18hg99r/2023_day_12_simple_tutorial_with_memoization/
#
# solve(springs, groups, cache, i):
# 	if num groups is 0:
# 		if any '#' remaining in springs return 0
# 		else return 1

# 	advance i to the next available '?' or '#'

# 	if i > length of springs return 0

# 	if (i, num groups) is in cache, return it

# 	if we can fill the springs at i with the first group in groups:
# 		recursively call with the groups after that at index: i + groupsize + 1

# 	if the current spot is '?':
# 		recursively call with current groups at the next index

# 	add the result to the cache
# 	return result