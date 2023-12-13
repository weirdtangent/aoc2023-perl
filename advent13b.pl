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

  if (!defined $vert && !defined $horz) {
    print "no smudge for map: $m with ".scalar(@{$maps[$m]})." rows\n\n";
    print join("\n", @{$maps[$m]})."\n\n";
    die;
  }

  $sum += $vert + $horz;
}
print "$sum\n";


sub horizontal {
  my (@map) = @_;

  my $smudge;
  for (my $row=0; $row < @map-1; $row++) {
    my $found = 0;
    if ($map[$row] eq $map[$row+1]) {
      $found = 1;
      for (my $c1=$row, $c2=$row+1; $c1>=0 && $c2<@map; $c1--, $c2++) {
        $found = 0 if $map[$c1] ne $map[$c2];
      }
      next if $found; # skip naturally found mirror
    }

    my $diffs = diffs($map[$row], $map[$row+1]);
    if ($diffs == 1) {
      $smudge = $row;
      for (my $c1=$row-1, $c2=$row+2; $c1>=0 && $c2<@map; $c1--, $c2++) {
        undef $smudge if $map[$c1] ne $map[$c2]; # no good, found another non-match
      }
    }
    if ($diffs == 0) {
      $smudge = $row;
      for (my $c1=$row, $c2=$row+1; $c1>=0 && $c2<@map; $c1--, $c2++) {
        undef $smudge if diffs($map[$c1], $map[$c2]) > 1; # no good, found more than a smudge
      }
    }
    return $smudge+1 if defined $smudge;
  }
  return undef;
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

sub diffs {
  my ($s1, $s2) = @_;

  my $diffs = 0;
  die if length($s1) != length($s2);

  my @s1 = split('', $s1);
  my @s2 = split('', $s2);

  for(my $x=0; $x<@s1; $x++) {
    $diffs++ if $s1[$x] ne $s2[$x];
  }
  return $diffs;
}
