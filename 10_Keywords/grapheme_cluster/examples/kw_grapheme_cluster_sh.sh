#!/usr/bin/env bash
# \X: one character as a person counts it, where the engine has it.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
. on e + combining accent :: .             :: e\u{301}
\X on e + accent          :: \X            :: e\u{301}
\X on a ZWJ sequence      :: \X            :: \u{1F468}\u{200D}\u{1F469}
\X on a flag pair         :: \X            :: \u{1F1EB}\u{1F1F7}
\X in JavaScript          :: \X            :: X
ROWS
