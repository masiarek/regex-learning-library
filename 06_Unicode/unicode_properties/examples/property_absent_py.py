#!/usr/bin/env python3
"""Python's `re` has no Unicode properties at all -- and says so, loudly.

The good news is the loudness. JavaScript without the `u` flag turns \\p{L}
into the literal text `p{L}` and never mentions it; `re` refuses to compile.
A pattern ported from Perl or PCRE fails on the line that compiles it, not in
production on the one input that happens to contain a Greek name.

Standard library only, on purpose: the third-party `regex` module does have
\\p{...}, and a page that quietly installed it would be teaching something the
reader's interpreter cannot do.
"""

import re
import unicodedata

CAST = [0x0009, 0x0037, 0x0041, 0x00A0, 0x00E9, 0x03B1, 0x0394, 0x0416, 0x0660, 0x2014, 0x4E2D]

print("re, asked for a Unicode property")
for pattern in (r"\p{L}", r"\P{L}", r"[\p{L}]", r"\pL", r"\p{Greek}"):
    try:
        re.compile(pattern)
        print(f"  {pattern:<10} compiles")
    except re.error as exc:
        print(f"  {pattern:<10} re.error: {exc}")

print("\nwhat the standard library offers instead")
print(f"  {'code point':<12}{'isalpha()':<11}{'isdecimal()':<13}category")
for cp in CAST:
    ch = chr(cp)
    print(f"  {cp:04X}{'':<8}{str(ch.isalpha()):<11}{str(ch.isdecimal()):<13}"
          f"{unicodedata.category(ch)}")

# An explicit range is the other stand-in. It is exact where you can name the
# block, and it is wrong the moment a script spills outside one -- Greek also
# lives in U+1F00..U+1FFF, and this class does not know that.
greek_block = re.compile(f"[{chr(0x0370)}-{chr(0x03FF)}]")
hit = [f"{cp:04X}" for cp in CAST if greek_block.fullmatch(chr(cp))]
print("\none script, spelled as an explicit range")
print(f"  [U+0370-U+03FF] matches: {' '.join(hit)}")
