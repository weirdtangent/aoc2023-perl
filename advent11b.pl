#!/usr/bin/perl

my $map;
my $col;
my $h;
my $w;
my $empty;
my $galaxy;

open(FH, "./input11");
my $r=0;
while (my $data = <FH>) {
  chomp $data;
  $w //= length($data);
  push @{$map->[$r++]}, split('', $data);
  $h++;
  if ($data =~ /^\.+$/) {
    $empty->{"r".$r} = 1;
  }
  my $c=0;
  foreach my $chr (split('', $data)) {
    $col->{$c++} .= $chr;
  }
}

for (my $x=0; $x<$w; $x++) {
  if ($col->{$x} =~ /^\.+$/) {
      $empty->{"c".$x} = 1;
  }
}

for (my $r=0; $r<$h; $r++) {
  for (my $c=0; $c<$w; $c++) {
    push @$galaxy, sprintf("%03d,%03d", $r, $c) if $map->[$r][$c] eq '#';
  }
}

my $sum=0;
for(my $g=0; $g<scalar(@$galaxy); $g++) {
  for(my $to=$g+1; $to<scalar(@$galaxy); $to++) {
    $sum += distance($g,$to);
  }
}

print "$sum\n";

sub distance() {
  my ($from, $to) = @_;

  my ($fromr,$fromc) = split(',', $galaxy->[$from]);
  my ($tor,$toc) = split(',', $galaxy->[$to]);

  $fromr+=0; $fromc+=0;$tor+=0;$toc+=0;

  my $steps=0;
  while ($fromr != $tor || $fromc != $toc) {
    if ($fromc != $toc) {
      $fromc += ($fromc > $toc ? -1 : 1);
      if (exists $empty->{"c".$fromc}) { $steps+=1_000_000; } else { $steps++; }
    } elsif ($fromr != $tor) {
      $fromr += ($fromr > $tor ? -1 : 1);
      if (exists $empty->{"r".$fromr}) { $steps+=1_000_000; } else { $steps++; }
    }
  }
  return $steps;
}