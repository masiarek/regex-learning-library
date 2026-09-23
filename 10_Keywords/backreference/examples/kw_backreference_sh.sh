#!/usr/bin/env bash
# \1 matches text, not a pattern. The keyword page; the chapter has the rest.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
plain                     :: (a)\1         :: xaay
unset group               :: (a)?b\1       :: b
forward reference         :: (?:\1x|(a))+  :: aax
\g{1} spelling            :: (a)\g{1}      :: aa
\g{-1} relative           :: (a)\g{-1}     :: aa
\k<1> spelling            :: (a)\k<1>      :: aa
\10 with one group        :: (a)\10        :: a\u{8}
case-insensitive backref  :: (?i)(a)\1     :: aA
ROWS
