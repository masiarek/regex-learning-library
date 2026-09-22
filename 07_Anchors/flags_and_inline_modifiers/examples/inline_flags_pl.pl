#!/usr/bin/env perl
# Perl's flag letters -- the ones every other engine copied, plus /xx, which is
# Perl's alone.
#
# Every pattern is a qr// so the flags travel with it, and the match runs inside
# show(), because $& is scoped to the block the match happened in.
#
# No version, path or error text is printed, so Perl 5.38 and Perl 5.42 produce
# byte-identical output.
use strict;
use warnings;

my $THREE = "one\ntwo\nthree";
my $CRLF  = "abc\r\ndef";

sub esc {
    my ($s) = @_;
    $s =~ s/\\/\\\\/g;
    $s =~ s/\n/\\n/g;
    $s =~ s/\r/\\r/g;
    return '"' . $s . '"';
}

sub show {
    my ( $label, $re, $subject ) = @_;
    printf "  %-30s %s\n", $label, $subject =~ $re ? 'match ' . esc($&) : 'no match';
}

print "== the dot: what it excludes ==\n";
print 'subject ' . esc("one\ntwo") . "\n";
show( 'one.two',     qr/one.two/,      "one\ntwo" );
show( 'one.two /s',  qr/one.two/s,     "one\ntwo" );
show( '(?s)one.two', qr/(?s)one.two/,  "one\ntwo" );
print 'subject ' . esc("one\rtwo") . "\n";
show( 'one.two', qr/one.two/, "one\rtwo" );

print "== the letter m: line anchors ==\n";
print 'subject ' . esc($THREE) . "\n";
show( '^two$',      qr/^two$/,     $THREE );
show( '^two$ /m',   qr/^two$/m,    $THREE );
show( '(?m)^two$',  qr/(?m)^two$/, $THREE );
show( 'one.two /m', qr/one.two/m,  $THREE );
print 'subject ' . esc($CRLF) . "\n";
show( '^abc$ /m',    qr/^abc$/m,    $CRLF );
show( '^abc\r?$ /m', qr/^abc\r?$/m, $CRLF );

print "== free-spacing: /x and /xx ==\n";
my $subject = 'due 2026-09-22 ok';
show( 'one line', qr/(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])/, $subject );
show(
    '/x',
    qr/
        (\d{4})                    # year
        -
        (0[1-9] | 1[0-2])          # month, 01-12
        -
        (0[1-9] | [12]\d | 3[01])  # day, 01-31
    /x,
    $subject
);
show( 'a b    /x  on ' . esc('a b'), qr/a b/x,     'a b' );
show( 'a b    /x  on ' . esc('ab'),  qr/a b/x,     'ab' );
show( 'a\ b   /x  on ' . esc('a b'), qr/a\ b/x,    'a b' );
show( 'a#b    /x  on ' . esc('a#b'), qr/a#b/x,     'a#b' );
show( '[a b]b /x  on ' . esc('a b'), qr/[a b]b/x,  'a b' );
show( '[a b]b /xx on ' . esc('a b'), qr/[a b]b/xx, 'a b' );

print "== inline and scoped modifiers ==\n";
show( 'abc            on ABC',  qr/abc/,             'ABC' );
show( 'abc /i         on ABC',  qr/abc/i,            'ABC' );
show( '(?i)abc        on ABC',  qr/(?i)abc/,         'ABC' );
show( '(?i:b)c        on Bc',   qr/(?i:b)c/,         'Bc' );
show( '(?i:b)c        on bC',   qr/(?i:b)c/,         'bC' );
show( '(?i)ab(?-i:cd) on ABcd', qr/(?i)ab(?-i:cd)/,  'ABcd' );
show( '(?i)ab(?-i:cd) on ABCD', qr/(?i)ab(?-i:cd)/,  'ABCD' );
show( 'a(?i)bc        on aBC',  qr/a(?i)bc/,         'aBC' );
show( 'a(?i)bc        on ABC',  qr/a(?i)bc/,         'ABC' );
show( '(a(?i)b)c      on aBc',  qr/(a(?i)b)c/,       'aBc' );
show( '(a(?i)b)c      on abC',  qr/(a(?i)b)c/,       'abC' );
