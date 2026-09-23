#!/usr/bin/env bash
# (?>...): once matched, never given back.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
(?>a+)a cannot match      :: (?>a+)a       :: aa
a+a can                   :: a+a           :: aa
atomic then other         :: (?>a+)b       :: aab
lookahead emulation       :: (?=(a+))\1a   :: aa
ROWS
