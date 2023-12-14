#!/usr/bin/perl

$| = 1;

use warnings;
use List::MoreUtils qw/true/;

my $row=0;
my @map;
my $size;
my $memo;

open(FH, "./input14");
my $s='';
while (my $data = <FH>) {
  chomp $data;
  $size //= length($data);
  $s .= $data;
}
close FH;
print "read\n$s\n\n";

for (my $c=0; $c < 1_000_000_000; $c++) {
  print '.' if $c && $c % 10_000_000 == 0;
  $s = $memo->{"CYCLE $s"}, next if exists $memo->{"CYCLE $s"};

  my $t = $s;
  $s=tilt('N',$s);
  $s=tilt('W',$s);
  $s=tilt('S',$s);
  $s=tilt('E',$s);
  $memo->{"CYCLE $t"} = $s;
}
print "\n\n";
printmap($s);

setmap($s);
my $sum = weight();
print $sum."\n";

sub tilt {
  my ($dir, $key) = @_;

  setmap($key);

  my $h = scalar @map;
  my $w = scalar @{$map[0]};
  die "wrong size: h = $h w = $w" if $h != $size || $w != $size;

  if ($dir eq 'N') {
    for (my $row=1; $row < $h; $row++) {
      for (my $col=0; $col < $w; $col++) {
        next unless $map[$row][$col] eq 'O' && $map[$row-1][$col] eq '.';
        my $dest = $row - 1;
        while ($dest >= 0 && $map[$dest][$col] eq '.') {
          $map[$dest][$col] = 'O';
          $map[$dest+1][$col] = '.';
          $dest--;
        }
      }
    }
  }

  if ($dir eq 'S') {
    for (my $row=$h-2; $row >= 0; $row--) {
      for (my $col=0; $col < $w; $col++) {
        next unless $map[$row][$col] eq 'O' && $map[$row+1][$col] eq '.';
        my $dest = $row + 1;
        while ($dest < $h && $map[$dest][$col] eq '.') {
          $map[$dest][$col] = 'O';
          $map[$dest-1][$col] = '.';
          $dest++;
        }
      }
    }
  }

  if ($dir eq 'W') {
    for (my $col=1; $col < $w; $col++) {
     for (my $row=0; $row < $h; $row++) {
        next unless $map[$row][$col] eq 'O' && $map[$row][$col-1] eq '.';
        my $dest = $col - 1;
        while ($dest >= 0 && $map[$row][$dest] eq '.') {
          $map[$row][$dest] = 'O';
          $map[$row][$dest+1] = '.';
          $dest--;
        }
      }
    }
  }

  if ($dir eq 'E') {
    for (my $col=$w-2; $col >= 0; $col--) {
     for (my $row=0; $row < $h; $row++) {
        next unless $map[$row][$col] eq 'O' && $map[$row][$col+1] eq '.';
        my $dest = $col + 1;
        while ($dest < $w && $map[$row][$dest] eq '.') {
          $map[$row][$dest] = 'O';
          $map[$row][$dest-1] = '.';
          $dest++;
        }
      }
    }
  }

  return getkey();
}

sub weight {
  my $weight = 0;

  for (my $row=0; $row < @map; $row++) {
    $weight += (scalar(@map) - $row) * (true { /O/ } @{$map[$row]});
  }

  return $weight;
}

sub getkey {
  my $s = "";
  for (my $row=0; $row < @map; $row++) {
    $s .= join('', @{$map[$row]});
  }
  return $s;
}

sub setmap {
  my ($key) = @_;

  undef @map;
  my $row = 0;
  while (my $sub = substr($key,0,$size)) {
    substr($key,0,$size) = '';
    push @{$map[$row]}, split('', $sub);
    $row++;
  }
}

sub printmap {
  my ($s) = @_;

  setmap($s);

  for (my $row=0; $row < @map; $row++) {
    print join('', @{$map[$row]})."\n";
  }
  print "\n";
}