#!/usr/bin/env bash
# a++: never give it back -- and the engine that reads it as something else.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
a++a can never match      :: a++a          :: aa
a+a can                   :: a+a           :: aa
possessive then other     :: a++b          :: aab
class then dot            :: \d++\.\d+     :: 3.14
*+ and ?+                 :: a*+b?+c       :: aabc
ROWS
