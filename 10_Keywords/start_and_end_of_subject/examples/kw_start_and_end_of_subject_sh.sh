#!/usr/bin/env bash
# \A, \z and \Z: three spellings, two meanings, one collision.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
\A start                  :: \Aa           :: ab
\A after a newline        :: \Aa           :: b\na
\A in JavaScript          :: \Aa           :: xAa
\A with the u flag        :: \Aa           :: xAa     :: node=u
\z end                    :: a\z           :: a
\z before final newline   :: a\z           :: a\n
\Z before final newline   :: a\Z           :: a\n
\Z before middle newline  :: a\Z           :: a\nb
\Z in JavaScript          :: a\Z           :: xaZ
ROWS
