#!/usr/bin/env perl
# \G is where the previous match ended. With /gc it turns a regex into a
# tokenizer: each match must start exactly where the last one stopped, and a
# failed match leaves pos() where it was instead of resetting it.
use strict;
use warnings;

my $src = "x = 42 + y7";
my @tokens;
pos($src) = 0;
while (pos($src) < length $src) {
    if    ($src =~ /\G\s+/gc)        { next }
    elsif ($src =~ /\G(\d+)/gc)      { push @tokens, "NUM($1)" }
    elsif ($src =~ /\G([A-Za-z_]\w*)/gc) { push @tokens, "ID($1)" }
    elsif ($src =~ /\G([=+])/gc)     { push @tokens, "OP($1)" }
    else {
        push @tokens, "ERROR at " . pos($src);
        last;
    }
}
print join(" ", @tokens), "\n";

# Without \G the same alternatives still match -- somewhere. The engine
# skips ahead to the first place a token fits, so a stray character is
# silently swallowed instead of reported.
my $bad = "x = 42 ? y7";
my @loose;
while ($bad =~ /(\d+|[A-Za-z_]\w*|[=+])/g) { push @loose, $1 }
print "without \\G: ", join(" ", @loose), "\n";

pos($bad) = 0;
my @strict;
while (pos($bad) < length $bad) {
    if    ($bad =~ /\G\s+/gc)                     { next }
    elsif ($bad =~ /\G(\d+|[A-Za-z_]\w*|[=+])/gc) { push @strict, $1 }
    else  { push @strict, "ERROR at " . pos($bad); last }
}
print "with \\G:    ", join(" ", @strict), "\n";
