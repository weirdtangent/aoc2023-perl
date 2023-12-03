#!/usr/bin/perl

my %v = ( one => 1, two => 2, three => 3, four => 4, five => 5, six => 6, seven => 7, eight => 8, nine => 9 );

my $sum = 0;
my $f;
my $l;
open(FH, "./input01");
while (<FH>) {
  chomp;
  ($f) = /^\D*?(\d|one|two|three|four|five|six|seven|eight|nine)/;
  do {
   ($l) = /(\d|one|two|three|four|five|six|seven|eight|nine)$/;
   chop $_ unless $l;
  } while (!$l && $_);
  $f = $v{$f} // $f;
  $l = $v{$l} // $l;
  $sum += ($f * 10 + $l);
  $f = $l = undef;
}
print $sum."\n";
