#!/usr/bin/env python3
r"""What \w, \d, \s and \b match in Python's `re`, once the subject is not ASCII.

Three modes, one question. A `str` pattern is Unicode-aware by default, the same
pattern with `re.ASCII` is not, and a `bytes` pattern has no choice: it is always
ASCII, because a byte is not a character.

Nothing here prints a non-ASCII character, and nothing here *contains* one: every
character is built with chr(), named by its code point, and every matched token is
escaped back to ASCII. So the recorded answer key is the same on macOS and on a
GitHub runner under LC_ALL=C.
"""

import json
import re

# One probe set, shared by every engine in this lesson, so the tables line up.
PROBES = [
    ("U+0041 LATIN CAPITAL LETTER A", chr(0x0041)),
    ("U+00E9 LATIN SMALL LETTER E WITH ACUTE", chr(0x00E9)),
    ("U+0301 COMBINING ACUTE ACCENT", chr(0x0301)),
    ("U+0660 ARABIC-INDIC DIGIT ZERO", chr(0x0660)),
    ("U+FF11 FULLWIDTH DIGIT ONE", chr(0xFF11)),
    ("U+00A0 NO-BREAK SPACE", chr(0x00A0)),
    ("U+3000 IDEOGRAPHIC SPACE", chr(0x3000)),
]

# "naive" with U+00EF LATIN SMALL LETTER I WITH DIAERESIS in the middle.
SUBJECT = "na" + chr(0x00EF) + "ve reader"

# "012" written with U+0660..U+0662 ARABIC-INDIC DIGIT ZERO..TWO.
ARABIC_INDIC = chr(0x0660) + chr(0x0661) + chr(0x0662)

ROW = "%-40s %-5s %-5s %s"


def esc(s: str) -> str:
    """Render a string as pure ASCII, so the key cannot depend on a locale."""
    return "".join(c if " " <= c <= "~" else "\\u%04X" % ord(c) for c in s)


def esc_bytes(b: bytes) -> str:
    return "".join(chr(x) if 0x20 <= x <= 0x7E else "\\x%02X" % x for x in b)


def table(title: str, flags: int) -> None:
    print(title)
    print(ROW % ("", "\\w", "\\d", "\\s"))
    for label, ch in PROBES:
        cells = ["yes" if re.fullmatch(p, ch, flags) else "no" for p in (r"\w", r"\d", r"\s")]
        print(ROW % (label, *cells))
    print()


table("str, default (Unicode):", 0)
table("str, re.ASCII:", re.ASCII)

print("bytes have no Unicode mode at all:")
print("  re.fullmatch(rb'\\w', b'\\xc3') ->",
      "yes" if re.fullmatch(rb"\w", b"\xc3") else "no",
      "  (one byte of the two that encode U+00E9)")
try:
    re.compile(rb"\w", re.UNICODE)
    print("  re.compile(rb'\\w', re.UNICODE) -> accepted")
except ValueError as exc:
    print("  re.compile(rb'\\w', re.UNICODE) ->", type(exc).__name__)
print()

print(r"\b\w+\b over 'na' U+00EF 've reader' -- how many words?")
for label, pat, subject in (
    ("str, default ", r"\b\w+\b", SUBJECT),
    ("str, re.ASCII", r"(?a)\b\w+\b", SUBJECT),
    ("bytes        ", rb"\b\w+\b", SUBJECT.encode("utf-8")),
):
    found = re.findall(pat, subject)
    shown = [esc(t) if isinstance(t, str) else esc_bytes(t) for t in found]
    print("  %s -> %d   %s" % (label, len(found), " ".join(shown)))
print()

print(r"\d and the number that follows it (subject is U+0660 U+0661 U+0662):")
print(r"  re.fullmatch(r'\d+')     ->", "yes" if re.fullmatch(r"\d+", ARABIC_INDIC) else "no")
print(r"  re.fullmatch(r'(?a)\d+') ->", "yes" if re.fullmatch(r"(?a)\d+", ARABIC_INDIC) else "no")
print("  int()                    ->", int(ARABIC_INDIC))
print("  float()                  ->", float(ARABIC_INDIC))
try:
    json.loads(ARABIC_INDIC)
    print("  json.loads()             -> accepted")
except json.JSONDecodeError as exc:
    print("  json.loads()             ->", type(exc).__name__)
try:
    ARABIC_INDIC.encode("ascii")
    print("  .encode('ascii')         -> accepted")
except UnicodeEncodeError as exc:
    print("  .encode('ascii')         ->", type(exc).__name__)
