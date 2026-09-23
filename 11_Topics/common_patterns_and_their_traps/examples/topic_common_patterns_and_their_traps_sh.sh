#!/usr/bin/env bash
# Six patterns everybody writes, and the input that each one gets wrong.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
email: \S+@\S+ takes two @  :: ^\S+@\S+$      :: a@b@c
email: one @ enforced       :: ^[^@\s]+@[^@\s]+$ :: a@b@c
IPv4: \d{1,3} allows 999    :: ^\d{1,3}(\.\d{1,3}){3}$ :: 999.999.999.999
date: shape is not validity :: ^\d{4}-\d\d-\d\d$ :: 2026-13-45
decimal: \d+\.\d+ on 1.2.3  :: \d+\.\d+       :: v1.2.3
decimal: \d+(\.\d+)? first  :: \d+(\.\d+)?    :: 1.2.3
quoted: "(.*)" is greedy    :: "(.*)"         :: "a" and "b"
quoted: "([^"]*)" is not    :: "([^"]*)"      :: "a" and "b"
number: -?\d+ on -          :: ^-?\d+$        :: -
number: .5 without a zero   :: ^\d+\.\d+$     :: .5
ROWS
