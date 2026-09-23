#!/usr/bin/env bash
# Splitting on a pattern: who keeps the captured delimiter, and who keeps the empties.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
plain delimiter             :: ;              :: a;b;c   :: split
captured delimiter          :: (;)            :: a;b;c   :: split
trailing empty piece        :: ;              :: a;b;    :: split
leading empty piece         :: ;              :: ;a      :: split
run of delimiters           :: ;+             :: a;;b    :: split
on whitespace               :: \s+            :: a b  c  :: split
zero-width split            :: (?=b)          :: abab    :: split
split on every character    :: (?:)           :: abc     :: split
ROWS
