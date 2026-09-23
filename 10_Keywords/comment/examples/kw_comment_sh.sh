#!/usr/bin/env bash
# (?#...) and the # of free-spacing mode.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
(?#...)                   :: a(?#note)b    :: ab
hash under (?x)           :: (?x)a#comment :: ab
hash without (?x)         :: a#b           :: a#b
ROWS
