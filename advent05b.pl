#!/usr/bin/perl

$| = 1;

my @seeds;
my %conversion;
my %chain;

open(FH, "./input05");
my $data = <FH>;
chomp $data;
$data =~ /seeds: (.*)/;
push @seeds, split(' ', $1);

my $source;
my $dest;

while (my $data = <FH>) {
  chomp $data;
  if (!$data) {
    $source = $desc = "";
  }
  elsif ($data =~ /(\w+)-to-(\w+) map:/) {
    $source = $1;
    $dest = $2;
    $chain{$dest} = $source;
    next;
  }
  else {
    my ($dest_num, $source_num, $range) = split(' ', $data);
    $key = sprintf("%d:%d", $dest_num, $dest_num+$range);
    $conversion{$dest}->{$key} = $source_num;
  }
}

my $lowest=0;
do {
  my $seed = follow("location", $lowest);
  print "$lowest...\n" if $lowest % 250_000 == 0;
  foreach (my $x=0; $x<@seeds; $x+=2) {
    print("lowest $lowest\n"), exit if $seed >= $seeds[$x] && $seed <= $seeds[$x] + $seeds[$x+1];
  }
  $lowest++;
} while 1;


sub follow() {
  my ($source, $num) = @_;

  my $dest = $chain{$source};
  foreach my $key (keys %{$conversion{$source}}) {
    my ($key_start, $key_end) = split(':', $key);
    next if $num < $key_start || $num > $key_end;
    $num = $num - $key_start + $conversion{$source}->{$key};
    last;
  }
  return $num if $dest eq "seed";
  return follow($dest, $num);
}

