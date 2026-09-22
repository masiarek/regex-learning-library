#!/usr/bin/env perl
# The three things a \p{...} can name, asked of one fixed cast of characters.
#
# Nothing here prints a character. Every character is written as a code point
# and reported as a code point, because this program's output is an answer key
# that has to be byte-identical on macOS and on Ubuntu -- and because a page
# that prints GREEK SMALL LETTER ALPHA teaches nothing a reader can type.
#
# The cast is deliberately boring: Latin, Greek, Cyrillic, Han, two digits, two
# spaces and a dash. Every one of them has had the same general category and
# the same script since the 1990s, so this key does not move when Perl is
# rebuilt against a newer Unicode.

use strict;
use warnings;

my @cast = (
    [ 0x0009, 'CHARACTER TABULATION' ],
    [ 0x0037, 'DIGIT SEVEN' ],
    [ 0x0041, 'LATIN CAPITAL LETTER A' ],
    [ 0x00A0, 'NO-BREAK SPACE' ],
    [ 0x00E9, 'LATIN SMALL LETTER E WITH ACUTE' ],
    [ 0x03B1, 'GREEK SMALL LETTER ALPHA' ],
    [ 0x0394, 'GREEK CAPITAL LETTER DELTA' ],
    [ 0x0416, 'CYRILLIC CAPITAL LETTER ZHE' ],
    [ 0x0660, 'ARABIC-INDIC DIGIT ZERO' ],
    [ 0x2014, 'EM DASH' ],
    [ 0x4E2D, 'CJK UNIFIED IDEOGRAPH-4E2D' ],
);

print "the cast\n";
printf "  %04X  %s\n", @$_ for @cast;

sub who {
    my ($pattern) = @_;
    my $re = qr/\A$pattern\z/;
    my @hit = map { sprintf '%04X', $_->[0] }
              grep { chr($_->[0]) =~ $re } @cast;
    printf "  %-23s %s\n", $pattern, (@hit ? join(' ', @hit) : '(nothing)');
}

print "\ngeneral category -- what KIND of character it is\n";
who($_) for ('\p{L}', '\p{Lu}', '\p{Ll}', '\p{Lo}', '\p{Nd}', '\p{Zs}', '\p{P}', '\P{L}');

print "\nscript -- what WRITING SYSTEM it belongs to\n";
who($_) for ('\p{Greek}', '\p{Cyrillic}', '\p{Script=Han}', '\p{Latin}');

print "\nbinary property -- one yes/no fact the standard records\n";
who($_) for ('\p{Alphabetic}', '\p{Uppercase}', '\p{White_Space}');

print "\ncomposed inside a character class\n";
who($_) for ('[\p{L}\p{Nd}]', '[\p{Greek}\p{Cyrillic}]', '[^\p{L}]');

# \X is one grapheme cluster: what a reader calls "one character". The subject
# is LATIN SMALL LETTER E followed by COMBINING ACUTE ACCENT -- two code
# points, one thing on the page.
my $subject = chr(0x0065) . chr(0x0301);
my $graphemes = () = $subject =~ /\X/g;
my $dots      = () = $subject =~ /./g;
print "\ngrapheme clusters in U+0065 U+0301\n";
printf "  %-23s %d\n", '\X', $graphemes;
printf "  %-23s %d\n", '.', $dots;
