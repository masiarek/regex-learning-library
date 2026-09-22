#!/usr/bin/env perl
# Perl is where this syntax comes from, and it has the widest spelling of it.
use v5.36;

my $text = "the the quick brown fox fox jumped over the lazy dog dog";

while ($text =~ /\b(\w+) \1\b/g) {
    printf "numbered   offset %2d  %-9s group 1 = %s\n", $-[0], "'$&'", "'$1'";
}

# \g{1} is the same thing written so that a digit may follow it: \g{1}1 is
# "group 1, then a literal 1", which \11 cannot say.
say "g{1}      ", ("aa1" =~ /^(a)\g{1}1$/ ? "matched" : "no match");

# \g{-1} counts backwards from where it is written, so copying a group into
# another pattern does not renumber the reference.
say "relative   ", ("abab" =~ /^(ab)\g{-1}$/ ? "matched" : "no match");

# Named, Perl's own spelling: \k<name> and \g{name} both work.
say "named      ", ("ho ho" =~ /\b(?<word>\w+) \k<word>\b/ ? "matched" : "no match");

say "unset group: ", ("" =~ /^(z)?\1$/ ? "empty match" : "failed");
