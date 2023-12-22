#!/usr/bin/perl

use strict;
use warnings;

use Storable qw/dclone/;
use List::Util qw/all any min/;
use Data::Dumper;

my @bricks;
my $world;

my $num = 0;
while (my $data = <>) {
  chomp $data;
  my ($l,$r) = $data =~ /(.+)~(.+)/;
  push @bricks, { num => $num++, l => $l, r => $r, supports => [], supportedBy => [] };
}

# add all bricks to our 3d world
foreach my $brick (@bricks) {
  addToWorld($brick);
}

# move all bricks as low as they can go
lowerAllBricks();

# how many bricks would fall IF one brick was removed
my $total = 0;
my $savedBricks = dclone(\@bricks);
my $savedWorld = dclone($world);

foreach my $try (@$savedBricks) {
  my $trynum = $try->{num};

  # reset bricks and 3d world, and then remove "try" brick from world
  undef @bricks;
  push @bricks, @{dclone($savedBricks)};
  $world = dclone($savedWorld);
  removeFromWorld($try);

  # now move "try" brick out of the way (and to ground)
  $bricks[$trynum]->{l} = '99,99,1';
  $bricks[$trynum]->{r} = '99,99,1';

  # ok, how many bricks fall NOW that the one was "removed"
  my $cnt = lowerAllBricks();
  $total += $cnt;
}
print "$total\n";



sub addToWorld {
  my ($brick) = @_;

  my ($lx,$ly,$lz) = split(',', $brick->{l});
  my ($rx,$ry,$rz) = split(',', $brick->{r});

  for my $x ($lx..$rx) { 
    for my $y ($ly..$ry) {
      for my $z ($lz..$rz) {
        $world->[$x][$y][$z] = $brick->{num};
      }
    }
  }
}

sub removeFromWorld {
  my ($brick) = @_;

  my ($lx,$ly,$lz) = split(',', $brick->{l});
  my ($rx,$ry,$rz) = split(',', $brick->{r});

  for my $x ($lx..$rx) { 
    for my $y ($ly..$ry) {
      for my $z ($lz..$rz) {
        undef $world->[$x][$y][$z];
      }
    }
  }
}

sub atBottom {
  my ($brick) = @_;

  my ($lx,$ly,$lz) = split(',', $brick->{l});
  my ($rx,$ry,$rz) = split(',', $brick->{r});

  return ($lz == 1 || $rz == 1);
}

sub isSupported {
  my ($brick) = @_;

  my ($lx,$ly,$lz) = split(',', $brick->{l});
  my ($rx,$ry,$rz) = split(',', $brick->{r});

  for my $x ($lx..$rx) { 
    for my $y ($ly..$ry) {
      for my $z ($lz..$rz) {
        return 1 if $z > 0 && defined $world->[$x][$y][$z-1] && $world->[$x][$y][$z-1] != $brick->{num};
      }
    }
  }
  return 0;
}

sub lowerAllBricks {
  my $cnt = 0;
  foreach my $brick (sort ascending_z @bricks) {
    my $lowered = 0;
    while (!atBottom($brick) && !isSupported($brick)) {
      $lowered = 1;
      removeFromWorld($brick);
      lowerBrick($brick);
      addToWorld($brick);
    }
    $cnt++ if $lowered;
  }
  return $cnt;
}

sub lowerBrick {
  my ($brick) = @_;

  my ($lx,$ly,$lz) = split(',', $brick->{l});
  my ($rx,$ry,$rz) = split(',', $brick->{r});

  $brick->{l} = join(',', $lx, $ly, $lz-1);
  $brick->{r} = join(',', $rx, $ry, $rz-1);
}

sub ascending_z {
  my ($alx, $aly, $alz) = split(',', $a->{l});
  my ($arx, $ary, $arz) = split(',', $a->{r});
  my ($blx, $bly, $blz) = split(',', $b->{l});
  my ($brx, $bry, $brz) = split(',', $b->{r});

  return min($alz,$arz) <=> min($blz,$brz);
}

