#!/usr/bin/env perl
# What \w, \d, \s and \b match in Perl -- and the one question Perl asks that no
# other engine on this page asks: is this string DECODED TEXT or is it BYTES?
#
# Every character is built with chr(), never written literally, so this file and
# everything it prints are pure ASCII.
use v5.36;

# The shared probe set. chr(0xE9) is one character, ord 233; chr(0x660) is one
# character, ord 1632. Perl stores the first as a byte and the second as UTF-8
# internally, and that storage detail is exactly what leaks below.
my @probes = (
    [ 'U+0041 LATIN CAPITAL LETTER A',          chr(0x0041) ],
    [ 'U+00E9 LATIN SMALL LETTER E WITH ACUTE', chr(0x00E9) ],
    [ 'U+0301 COMBINING ACUTE ACCENT',          chr(0x0301) ],
    [ 'U+0660 ARABIC-INDIC DIGIT ZERO',         chr(0x0660) ],
    [ 'U+FF11 FULLWIDTH DIGIT ONE',             chr(0xFF11) ],
    [ 'U+00A0 NO-BREAK SPACE',                  chr(0x00A0) ],
    [ 'U+3000 IDEOGRAPHIC SPACE',               chr(0x3000) ],
);

# "naive" with U+00EF LATIN SMALL LETTER I WITH DIAERESIS in the middle, twice:
# once as decoded text, once as the UTF-8 bytes a file would hand you unread.
my $text  = 'na' . chr(0x00EF) . 've reader';
my $bytes = 'na' . chr(0xC3) . chr(0xAF) . 've reader';

my $arabic_indic = chr(0x0660) . chr(0x0661) . chr(0x0662);    # "012"

sub esc ($s) { join '', map { ord($_) >= 0x20 && ord($_) <= 0x7E ? $_ : sprintf('\u%04X', ord $_) } split //, $s }
sub esc_b ($s) { join '', map { ord($_) >= 0x20 && ord($_) <= 0x7E ? $_ : sprintf('\x%02X', ord $_) } split //, $s }

say 'decoded text, default (unicode_strings, from use v5.36):';
printf "%-40s %-5s %-5s %s\n", '', '\w', '\d', '\s';
for my $p (@probes) {
    my ($label, $c) = @$p;
    printf "%-40s %-5s %-5s %s\n", $label,
        ($c =~ /^\w$/ ? 'yes' : 'no'),
        ($c =~ /^\d$/ ? 'yes' : 'no'),
        ($c =~ /^\s$/ ? 'yes' : 'no');
}
say '';

say 'the /a flag restricts the same pattern to ASCII:';
for my $p (@probes) {
    my ($label, $c) = @$p;
    printf "  %-40s \\w %-4s \\d %s\n", $label,
        ($c =~ /^\w$/a ? 'yes' : 'no'),
        ($c =~ /^\d$/a ? 'yes' : 'no');
}
say '';

# The "Perl Unicode bug": for ords 128..255 the answer used to depend on how the
# string happened to be stored. `use v5.36` turns on the unicode_strings feature,
# which settles it; turning the feature off shows what the old answer was.
say 'characters up to U+00FF without the unicode_strings feature (pre-5.12):';
{
    no feature 'unicode_strings';
    for my $p (@probes) {
        my ($label, $c) = @$p;
        next if ord($c) > 255;
        printf "  %-40s \\w %-4s \\s %s\n", $label,
            ($c =~ /^\w$/ ? 'yes' : 'no'),
            ($c =~ /^\s$/ ? 'yes' : 'no');
    }
}
say '';

say 'the same twelve characters of text, decoded and not decoded:';
printf "  decoded text  length %d   \\b\\w+\\b -> %d   %s\n",
    length($text), scalar(() = $text =~ /\b\w+\b/g),
    join ' ', map { esc($_) } $text =~ /\b\w+\b/g;
printf "  raw UTF-8     length %d   \\b\\w+\\b -> %d   %s\n",
    length($bytes), scalar(() = $bytes =~ /\b\w+\b/g),
    join ' ', map { esc_b($_) } $bytes =~ /\b\w+\b/g;
say '';

say 'a number that \d accepts and arithmetic does not (U+0660 U+0661 U+0662):';
printf "  =~ /^\\d+\$/   -> %s\n",  ($arabic_indic =~ /^\d+$/  ? 'yes' : 'no');
printf "  =~ /^\\d+\$/a  -> %s\n",  ($arabic_indic =~ /^\d+$/a ? 'yes' : 'no');
{
    no warnings 'numeric';
    printf "  0 + \$n       -> %s\n", 0 + $arabic_indic;
    printf "  sprintf %%d   -> %s\n", sprintf('%d', $arabic_indic);
}
