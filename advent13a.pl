#!/usr/bin/perl

my $map=0;
my @maps;

open(FH, "./input13");
while (my $data = <FH>) {
  chomp $data;
  if (length($data) > 3) {
    push @{$maps[$map]}, $data;
  }
  else { $map++; }
}

for(my $m=0; $m<=$map; $m++) {
  my $vert = vertical(@{$maps[$m]});
  my $horz = 100 * horizontal(@{$maps[$m]}) if !$vert;

  if (!$vert && !$horz) {
    print "no score for map: $m with ".scalar(@{$maps[$m]})." rows\n\n";
    print join("\n", @{$maps[$m]})."\n\n";
    die;
  }

  $sum += $vert + $horz;
}
print "$sum\n";


sub horizontal {
  my (@map) = @_;

  for (my $row=0; $row < @map-1; $row++) {
    my $found = 0;
    if ($map[$row] eq $map[$row+1]) {
      $found = 1;
      for (my $c1=$row, $c2=$row+1; $c1>=0 && $c2<@map; $c1--, $c2++) {
        $found = 0 if $map[$c1] ne $map[$c2];
      }
      return $row+1 if $found;
    }
  }
  return 0;
}

sub vertical {
  my (@map) = @_;

  my @rot;
  for (my $row=0; $row < @map; $row++) {
    my $r=0;
    foreach my $chr (split('', $map[$row])) {
      $rot[$r++] .= $chr;
    }
  }

  return horizontal(@rot);
}