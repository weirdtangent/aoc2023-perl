#!/usr/bin/perl

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
    $chain{$source} = $dest;
    next;
  }
  else {
    my ($dest_num, $source_num, $range) = split(' ', $data);
    $key = sprintf("%s:%d:%d", $source, $source_num, $source_num+$range);
    $conversion{$key} = sprintf("%s:%d", $dest, $dest_num);
  }
}

my $lowest;
foreach my $seed (@seeds) {
  my $location = follow("seed:$seed");
  if (!$lowest || $location < $lowest) {
    $lowest = $location;
  }
}

print $lowest."\n";

sub follow() {
  my ($key) = @_;

  my ($source,$num) = split(':', $key);
  if ($source eq "location") {
    return $num;
  }
  my $dest_key = $chain{$source}.":".$num; 
  foreach my $key (keys %conversion) {
    my ($key_source, $key_start, $key_end) = split(':', $key);
    next if $key_source ne $source;
    next if $num < $key_start || $num > $key_end;
    my ($dest, $dest_num) = split(':', $conversion{$key});
    my $new_num = $num - $key_start + $dest_num;
    $dest_key = $chain{$source}.":".$new_num;
    last;
  }

  return follow($dest_key);
}
    

