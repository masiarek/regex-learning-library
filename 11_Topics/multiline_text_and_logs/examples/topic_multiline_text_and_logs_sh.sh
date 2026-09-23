#!/usr/bin/env bash
# A pattern over lines: which flag, which newline, and what CRLF does to it.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
line anchors, no flag       :: ^b$            :: a\nb\nc
line anchors, (?m)          :: (?m)^b$        :: a\nb\nc
line anchors, node m flag   :: ^b$            :: a\nb\nc :: node=m
CRLF line, (?m)^b$          :: (?m)^b$        :: a\r\nb\r\nc
CRLF line, \r?$             :: (?m)^b\r?$     :: a\r\nb\r\nc
dot across lines            :: (?s)a.*c       :: a\nb\nc
dot across lines, Ruby (?m) :: (?m)a.*c       :: a\nb\nc
\R for any line break       :: a\Rb           :: a\r\nb
first line only             :: \A[^\n]*       :: first\nsecond
last line only              :: [^\n]*\z       :: first\nsecond
last line, Python's \Z       :: [^\n]*\Z      :: first\nsecond
ROWS
