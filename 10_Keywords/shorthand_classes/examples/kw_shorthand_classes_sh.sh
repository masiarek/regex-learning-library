#!/usr/bin/env bash
# \d \w \s -- and the ones only some engines have.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
\d on Arabic-Indic digits :: \d+           :: \u{660}\u{661}
\w on Latin-1             :: \w+           :: \u{E9}t\u{E9}
\w on Greek               :: \w+           :: \u{3B1}\u{3B2}
\s on no-break space      :: \s            :: \u{A0}
\h horizontal space       :: a\hb          :: a\tb
\v vertical space         :: a\vb          :: a\nb
\R any newline            :: a\Rb          :: a\r\nb
\N not a newline          :: a\Nb          :: axb
\D \W \S negations        :: \D\W\S        :: a b
ROWS
