#!/usr/bin/env bash
# What $ accepts before it says 'end', per engine.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
plain end                 :: a$            :: a
before a final newline    :: a$            :: a\n
before a middle newline   :: a$            :: a\nb
(?m) line end             :: (?m)a$        :: a\nb
node m flag               :: a$            :: a\nb    :: node=m
\z instead                :: a\z           :: a\n
\z in JavaScript          :: a\z           :: xaz
escaped dollar            :: \$5           :: \$5
mid-pattern $             :: a$b           :: a$b
ROWS
