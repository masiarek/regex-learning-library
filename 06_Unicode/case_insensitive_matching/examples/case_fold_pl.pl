#!/usr/bin/env perl
# What /i folds in Perl -- the one engine here that does FULL case folding.
#
# Every non-ASCII character is built with chr(), and named in the output by code
# point, so nothing depends on the locale or on this file's encoding.
use v5.36;
use feature 'fc';

my $KELVIN      = chr(0x212A);
my $LONG_S      = chr(0x017F);
my $SHARP_S     = chr(0x00DF);
my $CAP_SHARP_S = chr(0x1E9E);
my $DOTLESS_I   = chr(0x0131);
my $DOTTED_I    = chr(0x0130);
my $DOT_ABOVE   = chr(0x0307);

my @probes = (
    ["k",        "k",              "U+004B LATIN CAPITAL LETTER K",                "K"],
    ["k",        "k",              "U+212A KELVIN SIGN",                           $KELVIN],
    ["s",        "s",              "U+017F LATIN SMALL LETTER LONG S",             $LONG_S],
    ["U+00DF",   $SHARP_S,         "U+1E9E LATIN CAPITAL LETTER SHARP S",          $CAP_SHARP_S],
    ["U+1E9E",   $CAP_SHARP_S,     "U+00DF LATIN SMALL LETTER SHARP S",            $SHARP_S],
    ["ss",       "ss",             "U+00DF LATIN SMALL LETTER SHARP S",            $SHARP_S],
    ["[k]",      "[k]",            "U+212A KELVIN SIGN",                           $KELVIN],
    ["[a-z]",    "[a-z]",          "U+212A KELVIN SIGN",                           $KELVIN],
    ["i",        "i",              "U+0131 LATIN SMALL LETTER DOTLESS I",          $DOTLESS_I],
    ["i",        "i",              "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", $DOTTED_I],
    ["i U+0307", "i" . $DOT_ABOVE, "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", $DOTTED_I],
);

sub yn($hit) { $hit ? "yes" : "no" }

say "does (?i) match?          perl 5, anchored";
printf "%-9s %-46s %-5s%-6s%s\n", "pattern", "subject", "/i", "/ia", "/iaa";
for my $p (@probes) {
    my ($pat_name, $pat, $sub_name, $subject) = @$p;
    my $plain  = $subject =~ /\A(?i:$pat)\z/  ? "yes" : "no";
    my $ascii  = $subject =~ /\A(?ai:$pat)\z/ ? "yes" : "no";
    my $strict = $subject =~ /\A(?aai:$pat)\z/ ? "yes" : "no";
    printf "%-9s %-46s %-5s%-6s%s\n", $pat_name, $sub_name, $plain, $ascii, $strict;
}

say "";
say "does (?i) fold the BACKREFERENCE comparison too?";
printf "%-12s vs 'a' + U+0041            %s\n", '(?i)(a)\1', yn("aA" =~ /(?i)(a)\1/);
printf "%-12s vs 'k' + U+212A            %s\n", '(?i)(k)\1', yn("k$KELVIN" =~ /(?i)(k)\1/);

say "";
say "one program, two answers about the same pair";
printf "  fc: U+00DF eq 'ss'                    %-5s   regex /i: %s\n",
    (fc($SHARP_S) eq fc("ss") ? "true" : "false"), yn($SHARP_S =~ /\Ass\z/i);
printf "  fc: U+212A eq 'k'                     %-5s   regex /i: %s\n",
    (fc($KELVIN) eq fc("k") ? "true" : "false"), yn($KELVIN =~ /\Ak\z/i);
printf "  fc: U+017F eq 's'                     %-5s   regex /i: %s\n",
    (fc($LONG_S) eq fc("s") ? "true" : "false"), yn($LONG_S =~ /\As\z/i);
printf "  lc(U+1E9E) eq U+00DF                  %-5s   regex /i: %s\n",
    (lc($CAP_SHARP_S) eq $SHARP_S ? "true" : "false"), yn($CAP_SHARP_S =~ /\A$SHARP_S\z/i);
printf "  uc(U+00DF) is 2 code points           %-5s   regex /i: %s\n",
    (length(uc($SHARP_S)) == 2 ? "true" : "false"), yn($SHARP_S =~ /\ASS\z/i);
