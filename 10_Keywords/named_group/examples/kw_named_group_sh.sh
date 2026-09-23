#!/usr/bin/env bash
# Three spellings to define a name, four to refer to it.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
(?<w>...)                 :: (?<w>a)       :: a
(?P<w>...)                :: (?P<w>a)      :: a
(?'w'...)                 :: (?'w'a)       :: a
\k<w> backreference       :: (?<w>a)\k<w>  :: aa
(?P=w) backreference      :: (?P<w>a)(?P=w) :: aa
\g{w} backreference       :: (?<w>a)\g{w}  :: aa
same name twice           :: (?<w>a)|(?<w>b) :: b :: skip=node
ROWS
