#!/usr/bin/perl

use strict;
use warnings;

my %rules;
my $sum = 0;

while (my $data = <>) {
  chomp $data;
  last if $data eq '';
  my ($name, $rules) = $data =~ /(\w+)\{(.*)\}/;
  $rules =~ s/(\w)([<>]\d+)/\$$1$2/g;
  push @{$rules{$name}}, split(',', $rules);

}
while (my $data = <>) {
  my ($r) = $data =~ /\{(.*)\}/;
  my %rating;
  my $item_total = 0;
  foreach my $rating (split(',', $r)) {
    my ($code,$value) = split('=', $rating);
    $rating{$code} = $value;
    $item_total += $value;
  }

  my $wf = 'in';
  OUTER:
  while (1) {
    INNER:
    foreach my $rule (@{$rules{$wf}}) {
      if ($rule eq 'A') {
        $sum += $item_total;
        last OUTER;
      }
      elsif ($rule eq 'R') {
        last OUTER;
      }
      elsif ($rule =~ /^\w+$/) {
        $wf = $rule;
        last INNER;
      }
      else {
        my ($code,$check,$value,$goto) = $rule =~ /(\w+)([<>])(\d+):(\w+)/;
        if (($check eq '<' && $rating{$code} < $value) || ($check eq '>' && $rating{$code} > $value)) {
          if ($goto eq 'A') {
            $sum += $item_total;
            last OUTER;
          } elsif ($goto eq 'R') {
            last OUTER;
          } else {
            $wf = $goto;
            last INNER;
          }
        }
      }
    }
  }
}

print "$sum\n";
            




# px{a<2006:qkq,m>2090:A,rfg}
# pv{a>1716:R,A}
# lnx{m>1548:A,A}
# rfg{s<537:gd,x>2440:R,A}
# qs{s>3448:A,lnx}
# qkq{x<1416:A,crn}
# crn{x>2662:A,R}
# in{s<1351:px,qqz}
# qqz{s>2770:qs,m<1801:hdj,R}
# gd{a>3333:R,R}
# hdj{m>838:A,pv}

# {x=787,m=2655,a=1222,s=2876}
# {x=1679,m=44,a=2067,s=496}
# {x=2036,m=264,a=79,s=2244}
# {x=2461,m=1339,a=466,s=291}
# {x=2127,m=1623,a=2188,s=1013}
