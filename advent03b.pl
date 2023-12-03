#!/usr/bin/perl

my $row = 0;
my $col = 0;

my @map;
my %gearCount;
my %gearProduct;
my %unique;

open(FH, "./input03");
while (my $data = <FH>) {
  chomp $data;
  $row++;
  while ($data =~ /(\d+)/g) {
    my $num = $1;
    my $pos = pos($data);
    for (my $x=$pos-length($num)+1; $x<=$pos; $x++) {
      $map[$row][$x] = $1;
    }
    $unique{$num}++;
  }
  while ($data =~ /([^\.0-9])/g) {
    my $pos = pos($data);
    $map[$row][$pos] = $1;
  }
}

my $found = 0;
my $sum = 0;

for (my $y=1; $y<=140; $y++) {
  for (my $x=1; $x<=140; $x++) {
    $found=0,next unless $map[$y][$x] =~ /\d/;
    next if $found;
    if (my $key = foundSymbol($y,$x)) {
      $found=1;
      $gearProduct{$key} //= 1;
      $gearProduct{$key}  *= $map[$y][$x];
    }
  }
}

foreach (keys %gearCount) {
  $sum += $gearProduct{$_} if $gearCount{$_} == 2;
}

print "$sum\n";

sub foundSymbol {
  my ($y, $x) = @_;

  for (my $dy=-1; $dy<=1; $dy++) {
    for (my $dx=-1; $dx<=1; $dx++) {
      next if $y+$dy < 1 || $y+$dy > 140;
      next if $x+$dx < 1 || $x+$dx > 140;
      my $key = sprintf("%d,%d", $y+$dy, $x+$dx);
      if ($map[$y+$dy][$x+$dx] eq '*') {
        $gearCount{$key}++;
      }
      return $key if $map[$y+$dy][$x+$dx] =~ /[^\.0-9]/;
    }
  }
  return 0;
}
