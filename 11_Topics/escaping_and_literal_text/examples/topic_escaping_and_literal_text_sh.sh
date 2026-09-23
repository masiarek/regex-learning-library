#!/usr/bin/env bash
# Which characters need a backslash to be themselves, and where.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
unescaped dot               :: a.b            :: axb
escaped dot                 :: a\.b           :: axb
dot in a class              :: a[.]b          :: axb
escaped star                :: 2\*3           :: 2*3
escaped brackets            :: \[x\]          :: [x]
escaped braces              :: a\{2\}         :: a{2}
escaped backslash           :: a\\b           :: a\\b
hyphen outside a class      :: a-b            :: a-b
slash needs no escape       :: a/b            :: a/b
escaped letter: \e          :: \e             :: \u{1B}
escaped letter: \q          :: \q             :: q
ROWS
