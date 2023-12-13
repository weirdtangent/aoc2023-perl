#!/usr/bin/perl

my $row = 0;
my $sum = 0;

open(FH, "./input12");
while (my $data = <FH>) {
  chomp $data;
  my ($status, $counts) = $data =~ /^(\S+) (\S+)/;
  $row++;

  my $count = scalar(split(' ', try($status, $counts)));
  print "$row got $count\n";
  $sum += $count;
}
print "$sum\n";

sub try {
  my ($string, $counts) = @_;

  if ($string !~ /\?/) {
    return is_valid($string, $counts) ? "$string " : '';
  }
  my $try1 = $string;
  my $try2 = $string;
  $try1 =~ s/\?/\#/;
  $try2 =~ s/\?/\./;

  return try($try1, $counts) . try($try2, $counts);
}

sub is_valid {
  my ($string, $counts) = @_;

  $string =~ s/^\.*//;
  my $groups = join(',', map { length($_) } split(/\.+/, $string));
  return $groups eq $counts ? 1 : 0;
}