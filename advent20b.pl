#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use List::Util qw/max/;
use List::MoreUtils qw/true/;

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

my ($rxconj) = grep { $mods->{$_}->{dest}->[0] eq 'rx' } keys %$mods;

my @drivers = grep { $mods->{$_}->{dest}->[0] eq $rxconj } keys %$mods;
print '[' . join(',', @drivers) . "] all send pulses to [$rxconj] which sends to [rx]\n\n";

my %cycles;
my $pulses;

my $pushes=0;
while (1) {
  $pushes++;
  @process = ( { name => 'broadcaster', from => 'button', state => 0 } );
  process();

  # record as each of the drivers of the rx conjunction first get a low pulse
  foreach my $driver (@drivers) {
    next if exists $cycles{$driver};
    $cycles{$driver} = $pushes, print "found [$driver] at push count: $pushes\n" if exists $pulses->{$driver.'-0'};
  }

  last if keys %cycles == @drivers;
}

my $lcm = lcm($cycles{$drivers[0]}, lcm($cycles{$drivers[1]}, lcm($cycles{$drivers[2]}, $cycles{$drivers[3]})));
print "\n$lcm\n";

sub process {
  my $rx = 0;

  while (my $push = shift @process) {
    # print $push->{from}.' '.($push->{state} == 1 ? '-high' : '-low').'-> '.$push->{name}."\n";
    $pulses->{$push->{name}.'-'.$push->{state}}++;

    if ($push->{name} eq 'rx') {
      $rx = $push->{state};
      last if $rx == 0;
    }   

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
  
  return $rx;
}

sub pushOut {
  my ($from, $state, $dests) = @_;

  foreach my $dest (@$dests) {
    push @process, { name => $dest, from => $from, state => $state };
  }
}

sub lcm {
  my ($n1, $n2) = @_;

  my $highest = max($n1, $n2);
  my $lcm = $highest;
  while (1) {
    if ($lcm % $n1 == 0 && $lcm % $n2 == 0) {
      return $lcm;
    }
    $lcm += $highest;
  }
}