#!/usr/bin/env bash
# The features that make a long pattern reviewable, and who has each.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
free-spacing (?x)           :: (?x) \d{4} - \d\d :: 2026-09
comment under (?x)          :: (?x)\d{4}#year :: 2026
(?#…) comment               :: \d(?#a digit)\d :: 42
named group (?<y>…)         :: (?<y>\d{4})    :: 2026
named group (?P<y>…)        :: (?P<y>\d{4})   :: 2026
scoped flag (?i:…)          :: (?i:jan)uary   :: JANuary :: skip=node
DEFINE and a call           :: (?x)(?(DEFINE)(?<d>\d\d))^(?&d):(?&d)$ :: 09:30
ROWS
