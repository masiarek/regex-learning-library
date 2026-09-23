#!/usr/bin/env bash
# \G: the anchor that only means something in a loop.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
\G at the start           :: \Ga           :: aab
\G in JavaScript          :: \Ga           :: xGa
ROWS
