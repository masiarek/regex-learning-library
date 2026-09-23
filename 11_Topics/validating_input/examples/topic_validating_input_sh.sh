#!/usr/bin/env bash
# A validator is an anchored pattern, and the anchors are where it goes wrong.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
^\d+$ on a plain number     :: ^\d+$          :: 42
^\d+$ with a trailing \n    :: ^\d+$          :: 42\n
^\d+$ with a second line    :: ^\d+$          :: 42\nrm -rf /
\A\d+\z instead             :: \A\d+\z        :: 42\n
\A\d+\Z, Python's spelling  :: \A\d+\Z        :: 42\n
\d+ with no anchors         :: \d+            :: abc 42 def
\d+ on Arabic-Indic digits  :: ^\d+$          :: \u{660}\u{661}
[0-9]+ on the same          :: ^[0-9]+$       :: \u{660}\u{661}
(?i)[a-z]+ on KELVIN SIGN   :: (?i)^[a-z]+$   :: \u{212A}
[a-z]+ on KELVIN, node i    :: ^[a-z]+$       :: \u{212A} :: node=i
ROWS
