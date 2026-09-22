#!/usr/bin/env perl
# Balanced parentheses in Perl, which is where regex recursion was invented.
#
# Three spellings, one idea: a group may call itself.
#   (?R)      re-run the WHOLE pattern here
#   (?1)      re-run group 1's pattern here
#   (?&name)  re-run the named group's pattern here
use strict;
use warnings;

my @subjects = ('(a(b)c)', '((a)(b))', '()', '(a(b)c', 'a');

# (?R): the whole pattern, called from inside itself. Unanchored, so it finds
# the leftmost balanced run anywhere in the subject.
my $whole = qr/\((?:[^()]|(?R))*\)/;
print "(?R), unanchored\n";
for my $s (@subjects) {
    printf "  %-10s %s\n", $s, ($s =~ $whole ? "found '$&'" : 'no match');
}

# The trap: (?R) means the WHOLE pattern, anchors included. Wrap it in ^...$ and
# the recursive call tries to match ^ in the middle of the subject, which cannot
# succeed. The pattern compiles, and matches exactly the subjects that never
# enter the recursion -- so nesting silently stops working.
my $anchored_R = qr/^\((?:[^()]|(?R))*\)$/;
print "\n^...(?R)...\$ -- the anchors are INSIDE the recursion\n";
for my $s (@subjects) {
    printf "  %-10s %s\n", $s, ($s =~ $anchored_R ? 'match' : 'no match');
}

# (?1) calls group 1 only, so the anchors stay outside the recursion. This is
# the form you want when the question is "is the WHOLE string balanced?".
my $anchored_1 = qr/^(\((?:[^()]|(?1))*\))$/;
print "\n^((?1) form)\$ -- whole subject must be one balanced group\n";
for my $s (@subjects) {
    printf "  %-10s %s\n", $s, ($s =~ $anchored_1 ? 'match' : 'no match');
}

# (?&name) is the same call by name, which survives someone adding a group.
my $anchored_name = qr/^(?<par>\((?:[^()]|(?&par))*\))$/;
print "\n^((?&par) form)\$ -- the same thing, named\n";
for my $s (@subjects) {
    printf "  %-10s %s\n", $s, ($s =~ $anchored_name ? 'match' : 'no match');
}

# A subroutine call re-runs a PATTERN. A backreference re-matches TEXT. Same
# group, different question.
print "\nsubroutine call vs backreference\n";
for my $s ('12-34', '12-12') {
    printf "  %-8s (?1) %-3s  \\1 %s\n", $s,
        ($s =~ /^(\d\d)-(?1)$/ ? 'yes' : 'no'),
        ($s =~ /^(\d\d)-\1$/   ? 'yes' : 'no');
}

# Depth is bounded by the engine's recursion limit, not by the pattern.
print "\nnesting depth, with the (?1) form\n";
for my $depth (1, 10, 100, 1000) {
    my $s = ('(' x $depth) . ('a') . (')' x $depth);
    printf "  depth %-5d %s\n", $depth, ($s =~ $anchored_1 ? 'match' : 'no match');
}
