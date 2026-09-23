#!/usr/bin/env bash
# *? +? ?? {n,m}?: as little as possible, one more at a time.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
greedy                    :: <.+>          :: <b>x</b>
lazy                      :: <.+?>         :: <b>x</b>
?? prefers nothing        :: a??           :: a
{2,3}? stops at two       :: a{2,3}?       :: aaaa
lazy at the end           :: name=.*?      :: name=x
lazy, anchored            :: name=.*?$     :: name=x
ROWS
