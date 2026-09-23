#!/usr/bin/env bash
# \b is defined by \w, so every disagreement about \w is a disagreement about \b.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
whole word                :: \bcat\b       :: concat cat
not inside a word         :: \bcat\b       :: concat
\B inside a word          :: \Bcat         :: concat
Greek word, \b\w+\b       :: \b\w+\b       :: \u{3B1}\u{3B2}
Latin-1 word              :: \b\w+\b       :: na\u{EF}ve
boundary before digit     :: \b\d          :: a1 2
GNU \< \> spelling        :: \<cat\>       :: <cat>
\b inside a class         :: [\b]          :: \u{8}
ROWS
