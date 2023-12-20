#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Storable qw/dclone/;
use List::MoreUtils qw/true/;
use Test::Deep::NoTest;

my $mods;

while (my $data = <>) {
  chomp $data;
  my ($type, $name, $dests) = $data =~ /([%&]?)(\S+) -> (.*)/;

  my @dests = split(', ', $dests);
  $mods->{$name} = { name => $name, type => $type//'unknown', dest => \@dests, state => { } };
}

# initialize state hash for & and % types
$mods->{"broadcaster"}->{type} = 'broadcaster';
$mods->{"broadcaster"}->{state}->{self} = 0;
for my $modkey (keys %$mods) {
  my $mod = $mods->{$modkey};
  $mod->{state}->{self} = 0 if $mod->{type} eq '%';

  foreach my $dest (@{$mod->{dest}}) {
    next unless $dest && $mods->{$dest} && $mods->{$dest}->{name};
    $mods->{$dest}->{state}->{$modkey} = 0 if ($mods->{$dest}->{type}//'') eq '&';
  }
}

my @process;

my $ltotal = 0;
my $htotal = 0;

my $initial = dclone $mods;

for (my $pushes=0; $pushes<1000; $pushes++) {
  @process = ( { name => 'broadcaster', from => 'button', state => 0 } );
  my ($low, $high) = process();
  $ltotal += $low;
  $htotal += $high;

  # print(Dumper($mods)."\n\n".Dumper($initial)."\n eq_deeply = ".eq_deeply($mods, $initial)."\n") if $pushes == 3;

  if (eq_deeply($mods, $initial)) {
    print "\nstate returned to initial state after ".($pushes+1)." push(es): extrapolate\n\n";
    $ltotal *= 1000/($pushes+1);
    $htotal *= 1000/($pushes+1);
    last;
  }
}

print $ltotal * $htotal."\n";

sub process {
  my $lowcnt = 0;
  my $highcnt = 0;

  while (my $push = shift @process) {
    # print $push->{from}.' '.($push->{state} == 1 ? '-high' : '-low').'-> '.$push->{name}."\n";
    $push->{state} == 0 ? $lowcnt++ : $highcnt++;

    # just ignore a pulse to an undefined module (though, we "count" it above)
    next unless exists $mods->{$push->{name}};

    my $mod = $mods->{$push->{name}};

    if ($push->{name} eq 'broadcaster') {
      pushOut($push->{name}, $push->{state}, $mod->{dest});
    }
    elsif ($mod->{type} eq '%') { # flip-flop
      if ($push->{state} == 0) {
        $mod->{state}->{self} = $mod->{state}->{self} == 1 ? 0 : 1;
        pushOut($push->{name}, $mod->{state}->{self}, $mod->{dest});
      }
    }
    elsif ($mod->{type} eq '&') { # conjunction
      $mod->{state}->{$push->{from}} = $push->{state};
      my $state = (true { $mod->{state}->{$_} == 1 } keys %{$mod->{state}}) == scalar keys %{$mod->{state}} ? 0 : 1;
      pushOut($push->{name}, $state, $mod->{dest});
    }
    else { die "not sure what to do with ".$mod->{name}; }
  }
  
  return ($lowcnt, $highcnt);
}

sub pushOut {
  my ($from, $state, $dests) = @_;

  foreach my $dest (@$dests) {
    push @process, { name => $dest, from => $from, state => $state };
  }
}