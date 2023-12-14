#!/usr/bin/perl

use warnings;

use List::MoreUtils qw/true/;

my $row=0;
my @map;
open(FH, "./input14");
while (my $data = <FH>) {
  chomp $data;
  push @{$map[$row++]}, split('', $data);
  print "$data\n";
}

tilt('N');
print "\n";
for (my $row=0; $row < @map; $row++) {
  print join('', @{$map[$row]})."\n";
}
my $sum = weight();

print $sum."\n";

sub tilt {
  my ($dir) = @_;

  if ($dir eq 'N') {
    for (my $row=1; $row < @map; $row++) {
      for (my $col=0; $col < @{$map[$row]}; $col++) {
        next unless $map[$row][$col] eq 'O' && $map[$row-1][$col] eq '.';
        my $dest = $row - 1;
        while ($map[$dest][$col] eq '.') {
          $map[$dest][$col] = 'O';
          $map[$dest+1][$col] = '.';
          $dest--;
          last if $dest < 0;
        }
      }
    }
  }
}

sub weight {
  my $weight = 0;

  for (my $row=0; $row < @map; $row++) {
    $weight += (scalar(@map) - $row) * (true { /O/ } @{$map[$row]});
  }

  return $weight;
}