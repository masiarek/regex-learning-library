#!/usr/bin/env bash
# ( ) captures text, numbers itself by opening bracket, and keeps only the last iteration.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
group repeated            :: (ab)+         :: ababx
last iteration, $1        :: (a|b)+        :: ab      :: replace=[$1]
last iteration, \1        :: (a|b)+        :: ab      :: replace=[\1]
numbered by open bracket  :: ((a)(b))      :: ab      :: replace=$3$2
numbered, \3\2            :: ((a)(b))      :: ab      :: replace=\3\2
unset group in replace    :: (a)|(b)       :: b       :: replace=[$1]
unset group, \1           :: (a)|(b)       :: b       :: replace=[\1]
ROWS
