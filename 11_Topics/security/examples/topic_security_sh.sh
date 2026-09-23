#!/usr/bin/env bash
# The three regex mistakes that are vulnerabilities, in one table.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
$ lets a newline through    :: ^\d+$          :: 42\n
Ruby: $ lets a line through :: ^\d+$          :: 42\nrm -rf /
\A…\z does not              :: \A\d+\z        :: 42\n
(?i) folds KELVIN to k      :: (?i)^kelvin$   :: \u{212A}elvin
(?i)[a-z] admits KELVIN      :: (?i)^[a-z]+$   :: \u{212A}
[a-z] admits KELVIN, node i  :: ^[a-z]+$       :: \u{212A} :: node=i
\d admits non-ASCII digits  :: ^\d+$          :: \u{661}\u{662}
unescaped user text         :: ^user.name$    :: userXname
escaped user text           :: ^user\.name$   :: userXname
ROWS
