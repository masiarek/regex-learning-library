#!/usr/bin/env bash
# (?: ) groups without numbering -- and the scoped-flag form that grew out of it.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
grouping only             :: (?:ab)+       :: abab
does not shift numbers    :: (?:a)(b)      :: ab      :: replace=$1
does not shift, \1        :: (?:a)(b)      :: ab      :: replace=\1
scoped flag (?i:)         :: (?i:a)b       :: Ab      :: skip=node
scoped flag off (?-i:)    :: (?i)a(?-i:b)  :: AB      :: skip=node
ROWS
