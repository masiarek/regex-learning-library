#!/usr/bin/env bash
# \Q...\E: quote a run of metacharacters -- and the host-language function that does it better.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
\Q...\E quoted            :: \Qa.b\E       :: a.b
\Q...\E does not match x  :: \Qa.b\E       :: axb
\Q in JavaScript          :: \Qa.b\E       :: Qa.bE
\Q without \E             :: \Qa.b         :: a.b
ROWS
