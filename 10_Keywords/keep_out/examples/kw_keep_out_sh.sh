#!/usr/bin/env bash
# \K: keep everything before it out of the match.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
match after \K            :: foo\Kbar      :: foobar
replace after \K          :: foo\Kbar      :: foobar :: replace=X
\K in JavaScript          :: a\Kb          :: aKb
ROWS
