#!/usr/bin/env bash
# Brackets: ranges, negation, the two characters whose position matters, and set operations.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
range                     :: [a-c]+        :: xbcay
negated                   :: [^a-c]+       :: xbcay
] first is literal        :: []a]          :: ]
- last is literal         :: [a-]          :: -
escape inside             :: [\d.]+        :: 3.14
backslash-b is backspace  :: [\b]          :: \u{8}
intersection &&           :: [a-z&&[^aeiou]]+ :: aeb
nested class              :: [a[b]]        :: b
empty class               :: a[]b          :: ab
ROWS
