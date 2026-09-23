#!/usr/bin/env bash
# {n}, {n,}, {n,m} -- and the two spellings that are not the same everywhere.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
exactly two               :: a{2}          :: aaaa
two or more               :: a{2,}         :: aaaa
between one and two       :: a{1,2}        :: aaaa
{,2} up to two            :: a{,2}         :: aaaa
{2,1} backwards           :: a{2,1}        :: aa
{1001} large count        :: a{1001}
{2}{3} stacked            :: a{2}{3}       :: aaaaaaa
literal brace             :: a{            :: a{
literal brace, escaped    :: a\{           :: a{
ROWS
