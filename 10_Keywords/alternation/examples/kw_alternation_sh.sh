#!/usr/bin/env bash
# | -- the lowest-precedence operator, and the one whose order matters.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
first alternative wins    :: a|ab          :: ab
longer first              :: ab|a          :: ab
integer before decimal    :: \d+|\d+\.\d+  :: 3.14
decimal before integer    :: \d+\.\d+|\d+  :: 3.14
empty alternative         :: a|            :: b
lowest precedence         :: ^a|b$         :: xb
grouped                   :: ^(?:a|b)$     :: b
ROWS
