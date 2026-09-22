#!/usr/bin/env perl
# Perl compiles a forward reference, and it does useful work inside a repetition.
use v5.36;

# Pass 1: \1 is unset, so that branch fails and (a) runs, filling group 1.
# Pass 2: group 1 holds "a", so \1x matches "ax".
for my $s ("aax", "ax", "aaxx") {
    printf "%-5s %s\n", $s, ($s =~ /^(?:\1x|(a))+$/ ? "match" : "no match");
}

# The textbook pattern, which does NOT match here -- and the reason is not the
# forward reference. Perl keeps a capture across iterations of a quantifier, so
# pass 2 wants "onetwo" where only "two" is left.
say "onetwo: ", ("onetwo" =~ /^(\2two|(one))+$/ ? "match" : "no match");

# A reference to a group number the pattern never has is a different error, and
# Perl reports it at compile time like Python does.
# The pattern has to arrive as a string: a constant qr// is compiled when the
# PROGRAM is compiled, so eval around it would never see the error.
my $bad = '^(?:\2b|(a))+$';
my $err = do { local $@; eval { qr/$bad/ }; $@ };
$err =~ s/ at .*//s;
say "no such group: $err";
