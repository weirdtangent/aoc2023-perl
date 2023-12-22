#!/usr/bin/perl

use strict;
use warnings;

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
foreach my $brick (sort ascending_z @bricks) {
  while (!atBottom($brick) && !isSupported($brick)) {
    removeFromWorld($brick);
    lowerBrick($brick);
    addToWorld($brick);
  }
}

# set supports and supportedBy for every brick
foreach my $brick (sort ascending_z @bricks) {
  my ($lx,$ly,$lz) = split(',', $brick->{l});
  my ($rx,$ry,$rz) = split(',', $brick->{r});

  my %weknow;
  for my $x ($lx..$rx) { 
    for my $y ($ly..$ry) {
      for my $z ($lz..$rz) {
        if (defined $world->[$x][$y][$z+1] && $world->[$x][$y][$z+1] != $brick->{num} && !$weknow{$world->[$x][$y][$z+1]}) {
          push @{$brick->{supports}}, $world->[$x][$y][$z+1];                    # we support it
          push @{$bricks[$world->[$x][$y][$z+1]]->{supportedBy}}, $brick->{num}; # it is supportedBy us
          $weknow{$world->[$x][$y][$z+1]} = 1;
        }
      }
    }
  }
}

my $cnt = 0;
foreach my $brick (sort ascending_z @bricks) {
  $cnt++ if all { @{$bricks[$_]->{supportedBy}} > 1 } @{$brick->{supports}};
} 
print "$cnt\n";



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

