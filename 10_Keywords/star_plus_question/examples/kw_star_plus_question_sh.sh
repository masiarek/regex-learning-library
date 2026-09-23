#!/usr/bin/env bash
# *, + and ?: zero-or-more, one-or-more, optional -- and the empty match that * hands back.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
b* takes nothing          :: ab*c          :: ac
b+ needs one              :: ab+c          :: ac
b? takes at most one      :: ab?c          :: abbc
* on a subject with none  :: x*            :: abc
? is greedy too           :: a?a           :: a
stacked quantifiers x**   :: x**           :: xx
quantifier on nothing     :: *a            :: a
quantified group          :: (ab)+         :: ababx
ROWS
