#!/usr/bin/env bash
# The spellings that change meaning or stop compiling when a pattern moves.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
(?P<n>…) Python-style name  :: (?P<n>a)       :: a
(?<n>…) everyone else       :: (?<n>a)        :: a
\z true end                 :: a\z            :: a
\Z, two meanings            :: a\Z            :: a\n
\p{L}                       :: \p{L}          :: \u{3B1}
\h horizontal space         :: \h             :: \t
a++ possessive              :: a++a           :: aa
(?>…) atomic                :: (?>a+)a        :: aa
(?<=a|bc) two-width         :: (?<=a|bc)d     :: bcd
{,2} open lower bound       :: a{,2}          :: aaa
(?R) recursion              :: \((?:[^()]|(?R))*\) :: (a(b))
\Q…\E                       :: \Qa.b\E        :: a.b
ROWS
