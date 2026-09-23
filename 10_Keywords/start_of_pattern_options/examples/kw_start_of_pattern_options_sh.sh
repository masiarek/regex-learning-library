#!/usr/bin/env bash
# (*UCP), (*UTF), (*CRLF) and friends: PCRE2's leading options, which ABAP inherits.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
(*UCP)                    :: (*UCP)\w      :: \u{E9}
(*UTF)                    :: (*UTF)a       :: a
(*CRLF)                   :: (*CRLF)a$     :: a\r\n
(*LIMIT_MATCH=10)         :: (*LIMIT_MATCH=10)a :: a
ROWS
