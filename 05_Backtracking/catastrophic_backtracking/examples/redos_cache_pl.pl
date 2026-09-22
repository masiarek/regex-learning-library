#!/usr/bin/env perl
# Perl does not explode on the shapes this page is about -- and that is not the
# same as being safe.
#
# Perl's engine keeps a "super-linear cache": when a repetition reaches a
# position it has already failed from, it stops re-exploring. That turns the
# classic exponential shapes into polynomial ones, so every pattern below
# answers at 120 characters. The last two rows are the bill: polynomial on a
# field a user can make a megabyte long is still an outage.
#
# The cap is an alarm, and only the WORD "no answer" is recorded -- never a
# duration. The two subject sizes sit far either side of the cliff on purpose.

use strict;
use warnings;

my $CAP = 3;    # seconds before the match is abandoned

my $EMAIL       = '^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z]{2,4})+$';
my $EMAIL_FIXED = '^[a-zA-Z0-9_.-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4}$';

my $HOSTILE      = ( 'a' x 120 ) . '!';
my $BLANKS       = ( ' ' x 120 ) . '!';
my $MAIL_HOSTILE = 'a@a.' . ( 'a' x 120 ) . '!';
my $MEGABYTE     = ( 'a' x 1_000_000 ) . '!';

sub probe {
    my ( $pattern, $subject ) = @_;
    my $answer;
    local $SIG{ALRM} = sub { die "abandoned\n" };
    eval {
        alarm $CAP;
        $answer = ( $subject =~ /$pattern/ ) ? 'match' : 'no match';
        alarm 0;
        1;
    } or do { alarm 0; $answer = 'no answer' };
    return $answer;
}

sub table {
    my ( $title, @rows ) = @_;
    print "$title\n";
    for my $row (@rows) {
        my ( $pattern, $shown, $subject, $described ) = @$row;
        printf "  %-24s %-22s %s\n", $shown // $pattern, $described,
          probe( $pattern, $subject );
    }
}

print "\"no answer\" means the match was still running after $CAP seconds and was abandoned.\n\n";

table(
    'patterns with no backreference, perl:',
    [ '^(a+)+$',        undef,             $HOSTILE,      "120 a's then '!'" ],
    [ '^(a|a)*$',       undef,             $HOSTILE,      "120 a's then '!'" ],
    [ '^(\s*|\t)+$',    undef,             $BLANKS,       "120 spaces then '!'" ],
    [ '^(\w+\s?)*$',    undef,             $HOSTILE,      "120 a's then '!'" ],
    [ '^([a-z]{2,4})+$', undef,            $HOSTILE,      "120 a's then '!'" ],
    [ $EMAIL,           'the email regex', $MAIL_HOSTILE, q{a@a. 120 a's then '!'} ],
);

print "\n";
table(
    'the same patterns, on a field a user filled with a megabyte:',
    [ '^(a+)+$',   undef, $MEGABYTE, "1000000 a's then '!'" ],
    [ '^(?>a+)+$', undef, $MEGABYTE, "1000000 a's then '!'" ],
    [ '^a+$',      undef, $MEGABYTE, "1000000 a's then '!'" ],
);
