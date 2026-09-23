#!/usr/bin/env bash
# The four things ^ can mean, and where it stops meaning 'start of string'.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
start of subject          :: ^a            :: ab
second line, no flag      :: ^b            :: a\nb
second line, (?m)         :: (?m)^b        :: a\nb
second line, node m flag  :: ^b            :: a\nb    :: node=m
\A instead                :: \Ab           :: a\nb
\A in JavaScript          :: \Ab           :: xAb
mid-pattern ^             :: a^b           :: a^b
negation inside a class   :: [^a]          :: ba
literal inside a class    :: [a^]          :: ^
ROWS
