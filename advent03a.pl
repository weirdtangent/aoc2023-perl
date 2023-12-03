#!/usr/bin/perl

my $row = 0;
my $col = 0;

my @map;
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
  while ($data =~ /[^\.0-9]/g) {
    my $pos = pos($data);
    $map[$row][$pos] = "sym";
  }
}

my $found = 0;
my $sum = 0;

for (my $y=1; $y<=140; $y++) {
  for (my $x=1; $x<=140; $x++) {
    $found=0,next unless $map[$y][$x] =~ /\d/;
    next if $found;
    if (foundSymbol($y,$x)) {
      $found=1;
      $sum += $map[$y][$x];
    }
  }
}

print "$sum\n";

sub foundSymbol {
  my ($y, $x) = @_;

  for (my $dy=-1; $dy<=1; $dy++) {
    for (my $dx=-1; $dx<=1; $dx++) {
      next if $y+$dy < 1 || $y+$dy > 140;
      next if $x+$dx < 1 || $x+$dx > 140;
      return 1 if $map[$y+$dy][$x+$dx] eq 'sym';
    }
  }
  return 0;
}
