#!/usr/bin/env bash
# (*SKIP)(*FAIL), (*COMMIT), (*PRUNE), (*ACCEPT): steering the backtracker by hand.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
skip quoted, then comma   :: "[^"]*"(*SKIP)(*F)|, :: "a,b",c :: replace=X
same without the verbs    :: "[^"]*"|,     :: "a,b",c :: replace=X
(*COMMIT) forbids retry   :: a(*COMMIT)b|ac :: ac
same without (*COMMIT)    :: ab|ac         :: ac
(*PRUNE) forbids retry   :: a+(*PRUNE)ab  :: aab
same without (*PRUNE)    :: a+ab          :: aab
(*ACCEPT) ends early      :: a(*ACCEPT)b   :: ac
ROWS
