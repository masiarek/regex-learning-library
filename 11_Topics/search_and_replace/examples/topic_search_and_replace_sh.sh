#!/usr/bin/env bash
# The replacement side: first versus all, the template, and case-changing.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
first occurrence only       :: o              :: foo boo :: replace=0
$1 in the template          :: (\w+)@(\w+)    :: me@host :: replace=$2 at $1
\1 in the template          :: (\w+)@(\w+)    :: me@host :: replace=\2 at \1
\U$1 uppercases in Perl     :: (\w+)          :: word    :: replace=\U$1
empty match replaced        :: x*             :: ab      :: replace=-
lookahead keeps context     :: \d+(?= EUR)    :: 25 EUR  :: replace=NN
\K keeps the prefix         :: price=\K\d+    :: price=25 :: replace=NN
ROWS
