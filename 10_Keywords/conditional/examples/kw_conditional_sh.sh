#!/usr/bin/env bash
# (?(1)yes|no) and (?(DEFINE)...): the branch that depends on the match so far.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
optional bracket, closed  :: ^(<)?\w+(?(1)>)$ :: <tag>
optional bracket, bare    :: ^(<)?\w+(?(1)>)$ :: tag
optional bracket, open    :: ^(<)?\w+(?(1)>)$ :: <tag
named condition (?(<n>))  :: ^(?<b><)?\w+(?(<b>)>)$ :: <tag>
named condition (?(n))    :: ^(?P<b><)?\w+(?(b)>)$ :: <tag>
lookahead condition       :: ^(?(?=<)<\w+>|\w+)$ :: <tag>
DEFINE block              :: (?(DEFINE)(?<d>\d))^(?&d)$ :: 5
ROWS
