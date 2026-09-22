#!/usr/bin/env perl
# Perl invented the lazy quantifier, and PCRE2 -- and therefore ABAP -- follows
# it. This is the reference answer the rest of the page is compared against.
use strict;
use warnings;

my $subject = '<b>bold</b>';
print "subject       $subject\n";
for my $pattern ('<.+>', '<.+?>', '<[^>]+>') {
    my ($first) = $subject =~ /($pattern)/;
    my @all = $subject =~ /($pattern)/g;
    printf "  %-9s first '%s'  all [%s]\n", $pattern, $first,
        join(' ', map { "'$_'" } @all);
}

print "subject       aaa\n";
for my $pattern ('a+', 'a+?', 'a*?', 'a{1,3}?') {
    my ($first) = 'aaa' =~ /($pattern)/;
    printf "  %-9s first '%s'\n", $pattern, $first;
}
