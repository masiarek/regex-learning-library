#!/usr/bin/env perl
# In Perl the replacement is ordinary code, so the groups arrive as variables.
use v5.36;

my $iban = "DE44 5001 0517 5407 3249 31";
(my $grouped = $iban) =~ s/(\d{4}) (\d{4})/$1-$2/;
say $grouped;

# /r returns the changed copy and leaves the original alone.
say "order 42" =~ s/(\d+)/[$1]/r;

# ${1} is the form that survives a digit after it, the way \g<1> is in Python.
say "1234" =~ s/(\d{4})/${1}0/r;

# $& is the whole match; ${^PREMATCH} and friends need /p on old perls.
say "order 42" =~ s/\d+/<$&>/r;
