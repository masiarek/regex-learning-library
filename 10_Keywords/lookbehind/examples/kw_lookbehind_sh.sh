#!/usr/bin/env bash
# (?<=) and (?<!): assert what precedes -- and how wide it may be, per engine.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
fixed width               :: (?<=\$)\d+    :: $25
negative                  :: (?<!\$)\b\d+  :: $25 30
two widths                :: (?<=a|bc)d    :: bcd
bounded repeat            :: (?<=a{1,3})b  :: aab
unbounded                 :: (?<=a+)b      :: aab
ROWS
