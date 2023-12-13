#!/usr/bin/perl

$| = 1;

my $row = 0;
my $sum = 0;
my %memo;

open(FH, "./input12test2");
while (my $data = <FH>) {
  chomp $data;
  $row++;
  my ($status, $counts) = $data =~ /^(\S+) (\S+)/;

  my $count;
  %memo = undef;
  try($row, 0, $status, $counts, $status =~ /(\?+)$/ ? length($1) : 0);
  for (my $e=1; $e<5; $e++) {
    $count = 0;
    foreach (keys %{$memo{$e-1}}) {
      try($row, $e, "$_?$status", $counts.(",$counts" x $e), $status =~ /(\?+)$/ ? length($1) : 0);
    }
    $count = scalar (keys %{$memo{$e}});
    $memo{$e-1} = undef;
  }
  print "row $row got $count\n";
  $sum += $count;
}
print "$sum\n";

sub try {
  my ($row, $level, $string, $counts, $final) = @_;

  if ($string !~ /\?/) {
    my $valid = is_valid($string, $counts) ? 1 : 0;
    if ($valid) {
      $memo{$level}->{$string} = 1; # remember valid prefixes
      if ($final && $level < 4) { # if final chars WERE ?s we need to check those again with the next longer string
        $string =~ s/(.{$final,$final})$/'?' x length($1)/e;
        $memo{$level}->{$string} = 1;
      }
    }
    return $valid;
  }

  # check if what we have so far is working, retun 0 if we've already failed
  if (my ($check) = $string =~ /^\.*([\.\#]*)/) {
    my @counts = split(',', $counts);
    my @groups = map { length($_) } split(/\.+/, $check);
    foreach (@groups) {
      return 0 unless $_ <= shift @counts;
    }
  }

  my $try1 = $string;
  my $try2 = $string;
  $try1 =~ s/\?/\#/;
  $try2 =~ s/\?/\./;

  return try($row, $level, $try1, $counts, $final) + try($row, $level, $try2, $counts, $final);
}

sub is_valid {
  my ($string, $counts) = @_;

  $string =~ s/^\.*//;
  my $groups = join(',', map { length($_) } split(/\.+/, $string));
  return $groups eq $counts ? 1 : 0;
}