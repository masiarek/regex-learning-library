#!/usr/bin/env bash
# [[:alpha:]] and friends: who has them, and whether they mean ASCII.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
[[:digit:]]               :: [[:digit:]]+  :: a12
[[:alpha:]] on Greek      :: [[:alpha:]]+  :: \u{3B1}b
[[:word:]] on Latin-1     :: [[:word:]]+   :: \u{E9}a
[[:^digit:]] negation     :: [[:^digit:]]+ :: 12ab
\p{Alpha} on Greek        :: \p{Alpha}+    :: \u{3B1}b
outside brackets          :: [:digit:]+    :: 3:
ROWS
