#!/usr/bin/env bash
# The replacement string is a second little language, and no two engines share it.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
$1                        :: (a)(b)        :: ab      :: replace=$2$1
\1                        :: (a)(b)        :: ab      :: replace=\2\1
${1}                      :: (a)(b)        :: ab      :: replace=${2}${1}
$<name>                   :: (?<w>a)       :: a       :: replace=[$<w>]  :: skip=perl
${name}                   :: (?<w>a)       :: a       :: replace=[${w}]  :: skip=perl
\k<name>                  :: (?<w>a)       :: a       :: replace=[\k<w>]
\g<name>                  :: (?<w>a)       :: a       :: replace=[\g<w>]
$+{name} (Perl)           :: (?<w>a)       :: a       :: replace=[$+{w}]
whole match $&            :: a             :: xa      :: replace=[$&]
whole match $0            :: a             :: xa      :: replace=[$0]    :: skip=perl
whole match \0            :: a             :: xa      :: replace=[\0]
whole match \g<0>         :: a             :: xa      :: replace=[\g<0>]
literal dollar $$         :: a             :: a       :: replace=$$      :: skip=perl
literal dollar \$         :: a             :: a       :: replace=\$
ROWS
