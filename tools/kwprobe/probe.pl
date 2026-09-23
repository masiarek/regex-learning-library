#!/usr/bin/env perl
# The Perl column of tools/kwprobe/run.py. One cell per row on stdout.
#
# The pattern arrives in a variable, so `qr/$p/` compiles it at run time and
# `eval` can catch a refusal -- a constant qr// is compiled with the program.
# A replacement template is evaluated as a double-quoted Perl string, which
# is what Perl's own replacement language is: `$1`, `${1}`, `$&`, `$+{name}`
# and `\u` all mean what they mean in "...".
use strict;
use warnings;
no warnings;    # a refused or odd pattern may warn; the cell is the answer

sub decode {
    my ($s) = @_;
    $s =~ s/\\u\{([0-9A-Fa-f]+)\}/chr(hex($1))/ge;
    $s =~ s/\\n/\n/g; $s =~ s/\\r/\r/g; $s =~ s/\\t/\t/g; $s =~ s/\\\\/\\/g;
    return $s;
}

sub encode {
    my ($s) = @_;
    return '""' if $s eq '';
    my $out = '';
    for my $c (split //, $s) {
        my $o = ord $c;
        if    ($c eq "\\") { $out .= "\\\\" }
        elsif ($c eq "\n") { $out .= "\\n" }
        elsif ($c eq "\r") { $out .= "\\r" }
        elsif ($c eq "\t") { $out .= "\\t" }
        elsif ($o < 0x20 || $o > 0x7E) { $out .= sprintf("\\u{%X}", $o) }
        else { $out .= $c }
    }
    return $out;
}

open my $fh, '<:encoding(UTF-8)', $ARGV[0] or die $!;
while (my $line = <$fh>) {
    chomp $line;
    $line =~ s/^\s+|\s+$//g;
    next if $line eq '' || $line =~ /^#/;
    my @f = map { s/^\s+|\s+$//gr } split / :: /, $line;
    my $pattern = $f[1];
    my $subject = @f > 2 ? decode($f[2]) : undef;
    my ($replace, $split);
    my $skip = 0;
    for my $o (@f[3 .. $#f]) {
        if    ($o =~ /^replace=(.*)$/s) { $replace = decode($1) }
        elsif ($o eq 'split')           { $split = 1 }
        elsif ($o =~ /^skip=(.*)$/ && grep { $_ eq 'perl' } split /,/, $1) { $skip = 1 }
    }
    if ($skip) { print "n/a\n"; next }
    my $re = eval { qr/$pattern/ };
    if (!defined $re) { print "-\n"; next }
    if (!defined $subject) { print "ok\n"; next }
    if (defined $replace) {
        my $s = $subject;
        if ($s !~ $re) { print "no\n"; next }
        my $expr = '"' . $replace . '"';
        my $ok = eval { $s =~ s/$re/$expr/ee; 1 };
        print $ok ? encode($s) . "\n" : "err\n";
        next;
    }
    if ($split) {
        my @parts = split $re, $subject, -1;
        print '[' . join(',', map { $_ eq '' ? '' : encode($_) } @parts) . "]\n";
        next;
    }
    if ($subject =~ $re) { print encode($&) . "\n" } else { print "no\n" }
}
