#!/usr/bin/perl

$| = 1;

use strict;
use warnings;

use List::Util qw/min max/;

my %rules;
my $total = 0;

while (my $data = <>) {
  chomp $data;
  last if $data eq '';
  my ($name, $rules) = $data =~ /(\w+)\{(.*)\}/;
  $rules =~ s/(\w)([<>]\d+)/\$$1$2/g;
  push @{$rules{$name}}, split(',', $rules);
}

my $wf = 'in';
my %start = ( 'x' => undef, 'm' => undef, 'a' => undef, 's' => undef );

$total = follow($wf, '', %start);
print "$total\n";


sub follow {
  my ($wf, $path, %valid) = @_;

  my $sum = 0;
  my %start;

  $path .= $path ? " -> $wf" : $wf;
  foreach my $rule (@{$rules{$wf}}) {
    if (my ($code, $check, $value, $goto) = $rule =~ /(\w+)([<>])(\d+):(\w+)/) {
      # check if rule TRUE
      # print "checking path '$path' by going to $wf: WHEN $rule TRUE\n";
      %start = %valid;
      if ($goto eq 'R') {
        invalid($path, $rule, %start);
      }
      elsif ($start{$code} = setValid($code, $start{$code}, $check, $value)) {
        if ($goto eq 'A') {
          $sum += total($path, $rule, %start);
        } else {
          $sum += follow($goto, $path, %start);
        }
      } else {
        die "it wasn't possible\n";
      }

     # check if rule FALSE
      # print "checking path '$path' by going to $wf: WHEN $rule FALSE\n";
      %start = %valid;
      if ($start{$code} = setInvalid($code, $start{$code}, $check, $value)) {
        %valid = %start;
        next;
      }
    }
    invalid($path, $rule, %start), next if $rule eq 'R';
    $sum += total($path, $rule, %start), next if $rule eq 'A';
    $sum += follow($rule, $path, %start), next;
  }
  return $sum;
}

sub setValid {
  my ($code, $current, $check, $value) = @_;

  my ($min, $max);

  if (!$current) {
    ($min, $max) = ($check eq '<') ? (1,$value - 1) : ($value + 1, 4000);
  } else {
    ($min, $max) = split(' - ', $current);
    if ($check eq '<') {
      die "$code $current $check $value < $min" if $value < $min;
      $max = min($max, $value - 1);
    } else {
      die "$code $current $check $value > $max" if $value > $max;
      $min = max($min, $value + 1);
    }
  }

  # print "  $code was ".($current//'not set').", now valid if $min - $max\n";
  return "$min - $max";
}

sub setInvalid {
  my ($code, $current, $check, $value) = @_;

  my ($min, $max);

  if (!$current) {
    ($min, $max) = ($check eq '<') ? ($value, 4000) : (1, $value);
  } else {
    ($min, $max) = split(' - ', $current);
    if ($check eq '>') {
      die "$code $current $check $value < $min" if $value < $min;
      $max = min($max, $value);
    } else {
      die "$code $current $check $value > $max" if $value > $max;
      $min = max($min, $value);
    }
  }

  # print "  $code was ".($current//'not set').", now valid if $min - $max\n";
  return "$min - $max";
}

sub total {
  my ($path, $rule, %valid) = @_;

  my $total = 1;

  # print "VALID $path for rule $rule: ";
  foreach (sort keys %valid) {
    my $range = $valid{$_} // "1 - 4000";
    my ($min, $max) = split(' - ', $range);
    # print "$_ is $min-$max; ";
    $total *= ($max - $min + 1);
  }
  # print "\n\n";
  return $total;
}

sub invalid {
  my ($path, $rule, %valid) = @_;

  # print "INVALID $path for rule $rule\n\n";
}  
