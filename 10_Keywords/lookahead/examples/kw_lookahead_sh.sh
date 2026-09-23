#!/usr/bin/env bash
# (?=) and (?!): assert what follows, consume nothing -- and the negative that matches too much.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
positive                  :: \d+(?= EUR)   :: 25 EUR
negative, the trap        :: \d+(?! EUR)   :: 25 EUR
negative, fixed           :: \b\d+\b(?! EUR) :: 25 EUR
lookahead can capture     :: (?=(a+))\1    :: aaa
at the start              :: (?=.*\d)\w+   :: ab1
ROWS
