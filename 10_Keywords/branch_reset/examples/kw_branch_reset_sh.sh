#!/usr/bin/env bash
# (?|...): alternatives that share group numbers.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
branch reset              :: (?|(a)|(b))\1 :: bb
without it, \1 is unset   :: (?:(a)|(b))\1 :: bb
group number after it     :: (?|(a)|(b))(c) :: bc :: replace=$2$1
ROWS
