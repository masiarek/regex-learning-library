#!/usr/bin/env python3
"""What `re.IGNORECASE` folds in Python, and what `str.casefold()` folds instead.

Every non-ASCII character is built from its code point and named in the output
by code point, never printed -- so this program says the same thing in every
locale, on every machine, and in a terminal that cannot draw it.
"""

import re
import unicodedata

KELVIN = chr(0x212A)       # KELVIN SIGN, lowercases to plain "k"
LONG_S = chr(0x017F)       # LATIN SMALL LETTER LONG S, uppercases to "S"
SHARP_S = chr(0x00DF)      # LATIN SMALL LETTER SHARP S
CAP_SHARP_S = chr(0x1E9E)  # LATIN CAPITAL LETTER SHARP S
DOTLESS_I = chr(0x0131)    # LATIN SMALL LETTER DOTLESS I
DOTTED_I = chr(0x0130)     # LATIN CAPITAL LETTER I WITH DOT ABOVE
DOT_ABOVE = chr(0x0307)    # COMBINING DOT ABOVE

PROBES = [
    ("k", "k", "U+004B LATIN CAPITAL LETTER K", "K"),
    ("k", "k", "U+212A KELVIN SIGN", KELVIN),
    ("s", "s", "U+017F LATIN SMALL LETTER LONG S", LONG_S),
    ("U+00DF", SHARP_S, "U+1E9E LATIN CAPITAL LETTER SHARP S", CAP_SHARP_S),
    ("U+1E9E", CAP_SHARP_S, "U+00DF LATIN SMALL LETTER SHARP S", SHARP_S),
    ("ss", "ss", "U+00DF LATIN SMALL LETTER SHARP S", SHARP_S),
    ("[k]", "[k]", "U+212A KELVIN SIGN", KELVIN),
    ("[a-z]", "[a-z]", "U+212A KELVIN SIGN", KELVIN),
    ("i", "i", "U+0131 LATIN SMALL LETTER DOTLESS I", DOTLESS_I),
    ("i", "i", "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I),
    ("i U+0307", "i" + DOT_ABOVE, "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I),
]


def cps(text):
    return " ".join(f"U+{ord(c):04X}" for c in text)


def yn(hit):
    return "yes" if hit else "no"


def match_str(pattern, subject, flags=0):
    return re.fullmatch(pattern, subject, re.IGNORECASE | flags) is not None


def match_bytes(pattern, subject):
    try:
        return re.fullmatch(pattern.encode(), subject.encode(), re.IGNORECASE) is not None
    except re.error:
        return False


print("does (?i) match?          python 3, re.fullmatch")
print(f"{'pattern':<9} {'subject':<46} {'str':<5}{'re.A':<6}bytes")
for pat_name, pattern, sub_name, subject in PROBES:
    print(
        f"{pat_name:<9} {sub_name:<46} "
        f"{yn(match_str(pattern, subject)):<5}"
        f"{yn(match_str(pattern, subject, re.ASCII)):<6}"
        f"{yn(match_bytes(pattern, subject))}"
    )

print()
print("does (?i) fold the BACKREFERENCE comparison too?")
print(f"{'(?i)(a)' + chr(92) + '1':<12} vs 'a' + U+0041            "
      f"{yn(re.search('(?i)(a)' + chr(92) + '1', 'aA') is not None)}")
print(f"{'(?i)(k)' + chr(92) + '1':<12} vs 'k' + U+212A            "
      f"{yn(re.search('(?i)(k)' + chr(92) + '1', 'k' + KELVIN) is not None)}")

print()
print("one program, two answers about the same pair")
print(f"  str.casefold: U+00DF == 'ss'          {str(SHARP_S.casefold() == 'ss'.casefold()):<5}"
      f"   re (?i): {yn(match_str('ss', SHARP_S))}")
print(f"  str.casefold: U+212A == 'k'           {str(KELVIN.casefold() == 'k'.casefold()):<5}"
      f"   re (?i): {yn(match_str('k', KELVIN))}")
print(f"  str.casefold: U+017F == 's'           {str(LONG_S.casefold() == 's'.casefold()):<5}"
      f"   re (?i): {yn(match_str('s', LONG_S))}")
print(f"  str.lower(U+1E9E) == U+00DF           {str(CAP_SHARP_S.lower() == SHARP_S):<5}"
      f"   re (?i): {yn(match_str(SHARP_S, CAP_SHARP_S))}")
print(f"  str.upper(U+00DF) is 2 code points    {str(len(SHARP_S.upper()) == 2):<5}"
      f"   re (?i): {yn(match_str('SS', SHARP_S))}")

print()
print("normalise first, then fold -- what the advice at the end of the page does")
for name, ch in [("U+212A", KELVIN), ("U+017F", LONG_S),
                 ("U+00DF", SHARP_S), ("U+1E9E", CAP_SHARP_S)]:
    nfkc = unicodedata.normalize("NFKC", ch)
    print(f"  NFKC({name}) = {cps(nfkc):<14} and casefolded = {cps(nfkc.casefold())}")
