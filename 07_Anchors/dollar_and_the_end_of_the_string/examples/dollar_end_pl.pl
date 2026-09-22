#!/usr/bin/env perl
# `$` in Perl is "end of string, or just before a newline at the end of it".
# Perl is where that definition comes from; everyone who copied `$` from Perl
# either copied the newline clause with it (Java) or did not (JavaScript, Go).
use strict;
use warnings;

# Printed escaped, because one subject contains a newline.
my @subjects = ("1", "1\n", "1\nrm -rf /");

sub row {
    my ($label, $a, $b, $c) = @_;
    printf "%-30s%-8s%-8s%s\n", $label, $a, $b, $c;
}

sub verdicts {
    my ($test) = @_;
    return map { $test->($_) ? "match" : "no" } @subjects;
}

print "perl\n";
row("pattern", '"1"', '"1\n"', '"1\nrm -rf /"');
row('/^\d+$/',    verdicts(sub { $_[0] =~ /^\d+$/ }));
row('/\A\d+\z/',  verdicts(sub { $_[0] =~ /\A\d+\z/ }));
row('/\A\d+\Z/',  verdicts(sub { $_[0] =~ /\A\d+\Z/ }));
row('/^\d+$/m',   verdicts(sub { $_[0] =~ /^\d+$/m }));

# What `$` let through. The capture is "1"; the newline is still in the value.
"1\n" =~ /^(\d+)$/;
print "\n";
printf "/^(\\d+)\$/ on \"1\\n\" captured '%s'; the subject is still %d chars\n",
    $1, length("1\n");

# The flag letters, which are not the same letters everywhere: in Perl /m is
# the line-anchor flag and /s is the dot flag. Ruby spells the dot flag /m.
print "\n";
row("flag", "none", "/m", "/s");
row('^\d+$ on "1\nrm -rf /"',
    ("1\nrm -rf /" =~ /^\d+$/)  ? "match" : "no",
    ("1\nrm -rf /" =~ /^\d+$/m) ? "match" : "no",
    ("1\nrm -rf /" =~ /^\d+$/s) ? "match" : "no");
row('a.b on "a\nb"',
    ("a\nb" =~ /a.b/)  ? "match" : "no",
    ("a\nb" =~ /a.b/m) ? "match" : "no",
    ("a\nb" =~ /a.b/s) ? "match" : "no");
