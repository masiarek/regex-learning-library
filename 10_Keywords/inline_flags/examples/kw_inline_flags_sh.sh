#!/usr/bin/env bash
# (?i) (?m) (?s) (?x) and the rest: a flag that travels with the pattern.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
(?i)                      :: (?i)a         :: A
(?i) mid-pattern          :: a(?i)b        :: aB
(?i) then (?-i)           :: (?i)a(?-i)b   :: AB
(?s)                      :: (?s)a.b       :: a\nb
(?m)                      :: (?m)^b        :: a\nb
(?x) free-spacing         :: (?x) a  b     :: ab
(?U) ungreedy             :: (?U)a+        :: aa
(?a) ASCII                :: (?a)\w        :: \u{E9}
(?u)                      :: (?u)\w        :: \u{E9}
(?d) UNIX_LINES           :: (?d)a$        :: a\r\n
unknown flag              :: (?z)a         :: a
ROWS
