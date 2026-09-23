#!/usr/bin/env bash
# One subject, one row per question: is the engine thinking in ASCII, code units, or code points?
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
\w on an accented letter    :: ^\w$           :: \u{E9}
\d on an Arabic-Indic digit :: ^\d$           :: \u{663}
\p{L} on Greek              :: ^\p{L}$        :: \u{3B1}
\p{L} on Greek, node u      :: ^\p{L}$        :: \u{3B1}   :: node=u
. on an emoji               :: ^.$            :: \u{1F600}
. on an emoji, node u       :: ^.$            :: \u{1F600} :: node=u
. on e + combining accent   :: ^.$            :: e\u{301}
\X on e + combining accent  :: ^\X$           :: e\u{301}
(?i) on LONG S vs s         :: (?i)^s$        :: \u{17F}
(?i) on sharp s vs ss       :: (?i)^ss$       :: \u{DF}
ROWS
