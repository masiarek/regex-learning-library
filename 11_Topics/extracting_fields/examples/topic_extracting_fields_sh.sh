#!/usr/bin/env bash
# Pulling a date apart: groups, names, and what the engine hands back.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
whole match                 :: (\d{4})-(\d\d)-(\d\d) :: on 2026-09-22 at
year via $1                 :: (\d{4})-(\d\d)-(\d\d) :: 2026-09-22 :: replace=$1
year via \1                 :: (\d{4})-(\d\d)-(\d\d) :: 2026-09-22 :: replace=\1
named, (?<y>…) and ${y}     :: (?<y>\d{4})-(?<m>\d\d)-(?<d>\d\d) :: 2026-09-22 :: replace=${d}/${m}/${y} :: skip=perl
named, (?P<y>…) and \g<y>   :: (?P<y>\d{4})-(?P<m>\d\d)-(?P<d>\d\d) :: 2026-09-22 :: replace=\g<d>/\g<m>/\g<y>
last iteration of a group   :: (\d+,)+        :: 1,2,3, :: replace=[$1]
optional field, unset       :: (\d+)(?:\.(\d+))? :: 42     :: replace=int=$1 frac=[$2]
ROWS
