#!/usr/bin/env bash
# \p{...}: the spellings, measured. The lesson page has the depth.
#
# Each row is one pattern and one subject, put to eight engines by
# tools/kwprobe/run.py; the cell is what that engine matched, `no`, or `-`
# when it refused the pattern. See the driver's docstring for the cells.
set -u
python3 ../../../tools/kwprobe/run.py <<'ROWS'
\p{L} letter              :: \p{L}+        :: \u{3B1}b1
\p{L} node u flag         :: \p{L}+        :: \u{3B1}b1 :: node=u
\pL no braces             :: \pL+          :: \u{3B1}b1
\p{Lu} uppercase          :: \p{Lu}        :: a\u{394}
\p{Greek}                 :: \p{Greek}+    :: a\u{3B1}\u{3B2}
\p{Script=Greek}          :: \p{Script=Greek}+ :: a\u{3B1}
\p{IsGreek}               :: \p{IsGreek}+  :: a\u{3B1}
\P{L} not a letter        :: \P{L}         :: a1
\p{Nd} decimal digit      :: \p{Nd}        :: a\u{660}
ROWS
