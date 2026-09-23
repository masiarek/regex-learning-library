#!/usr/bin/env bash
# (?R), (?1), (?&name), \g<0>: two dialects with no overlap.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
(?R) whole pattern        :: \((?:[^()]|(?R))*\) :: (a(b)c)
(?1) group one            :: (\((?:[^()]|(?1))*\)) :: (a(b)c)
(?&name)                  :: (?<p>\((?:[^()]|(?&p))*\)) :: (a(b)c)
\g<0> Ruby spelling       :: \((?:[^()]|\g<0>)*\) :: (a(b)c)
\g<name> Ruby spelling    :: (?<p>\((?:[^()]|\g<p>)*\)) :: (a(b)c)
subroutine vs backref     :: (\d\d)-(?1)   :: 12-34
backref for comparison    :: (\d\d)-\1     :: 12-34
ROWS
