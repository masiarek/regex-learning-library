#!/usr/bin/env perl
# Perl has the whole conditional family: by number, by name in two spellings,
# and with a lookaround as the condition. It also has (?(DEFINE)...).
#
# Nothing here prints Perl's own error text -- only fixed labels chosen in this
# file -- because those messages get reworded between releases.

use strict;
use warnings;

my @subjects = ("<tag>", "tag", "<tag");

sub row {
    my ($label, $pattern) = @_;
    # The pattern has to arrive as a STRING: a constant qr// is compiled when
    # the program is compiled, so eval would never see the failure.
    my $rx = eval { qr/$pattern/ };
    if ($@) { printf "%-30s compile error\n", $label; return }
    my $cells = join "", map { sprintf "%-7s", ($_ =~ /$rx/ ? "yes" : "no") } @subjects;
    my $line = sprintf "%-30s %s", $label, $cells;
    $line =~ s/\s+$//;
    print "$line\n";
}

my $head = sprintf "%-30s %-7s%-7s%-7s", "", "<tag>", "tag", "<tag";
$head =~ s/\s+$//;
print "$head\n";

row("numbered   (?(1)>)",        '^(<)?\w+(?(1)>)$');
row("named      (?(<open>)>)",   '^(?<open><)?\w+(?(<open>)>)$');
row("named      (?(open)>)",     '^(?<open><)?\w+(?(open)>)$');
row("lookaround (?(?=<)...|...)",'^(?(?=<)<\w+>|\w+)$');

print "\n";

# A condition naming a group that is not in the pattern. PCRE2 calls this a
# compile error; Perl does not, and quietly takes the no-branch.
my $missing_src = '^(a)(?(2)x|y)$';
my $missing = eval { qr/$missing_src/ };
printf "(a)(?(2)x|y) with no group 2: %s\n", ($@ ? "compile error" : "compiled");
for my $s ("ay", "ax") {
    printf "(a)(?(2)x|y)       on %-3s %s\n", $s, ($s =~ /$missing/ ? "yes" : "no");
}

print "\n";

# (?(R)...) is the RECURSION test: accepted with no group named R anywhere, and
# simply false outside a recursive call.
for my $s ("ay", "ax") {
    printf "(a)(?(R)x|y)       on %-3s %s\n", $s, ($s =~ /^(a)(?(R)x|y)$/ ? "yes" : "no");
}

# And Perl gives that reading priority over a group that really is named R.
# The same pattern in pcre2grep answers the other way.
for my $s ("xy", "xn") {
    printf "(?<R>x)(?(R)y|n)   on %-3s %s\n", $s, ($s =~ /^(?<R>x)(?(R)y|n)$/ ? "yes" : "no");
}
for my $s ("xy", "xn") {
    printf "(?<R>x)(?(<R>)y|n) on %-3s %s\n", $s, ($s =~ /^(?<R>x)(?(<R>)y|n)$/ ? "yes" : "no");
}

print "\n";

# (?(DEFINE)...) defines named parts and matches nothing itself. With /x the
# result is a pattern a reviewer can read line by line.
my $ipv4 = qr{
    (?(DEFINE)
        (?<octet>  25[0-5] | 2[0-4]\d | 1\d\d | [1-9]?\d )
    )
    ^ (?&octet) \. (?&octet) \. (?&octet) \. (?&octet) $
}x;

for my $s ("192.168.0.1", "255.255.255.255", "256.1.1.1", "1.2.3", "01.2.3.4") {
    printf "ipv4 %-16s %s\n", $s, ($s =~ $ipv4 ? "yes" : "no");
}

# The block really does consume nothing: on its own it matches the empty string
# and nothing else.
my $only_define = qr{^(?(DEFINE)(?<octet>\d+))$};
printf "the DEFINE block alone, on the empty string: %s\n",
    ("" =~ $only_define ? "yes" : "no");
printf "the DEFINE block alone, on '7':              %s\n",
    ("7" =~ $only_define ? "yes" : "no");
