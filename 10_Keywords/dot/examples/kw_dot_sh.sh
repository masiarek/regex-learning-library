#!/usr/bin/env bash
# Which characters . refuses, and the flag that changes it -- with three different names.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
ordinary                  :: a.b           :: axb
across \n                 :: a.b           :: a\nb
across \n with (?s)       :: (?s)a.b       :: a\nb
across \n, node s flag    :: a.b           :: a\nb    :: node=s
across \n with (?m)       :: (?m)a.b       :: a\nb
across \r                 :: a.b           :: a\rb
one astral character      :: ^.$           :: \u{1F600}
astral, node u flag       :: ^.$           :: \u{1F600} :: node=u
escaped dot               :: a\.b          :: axb
dot inside a class        :: a[.]b         :: axb
ROWS
