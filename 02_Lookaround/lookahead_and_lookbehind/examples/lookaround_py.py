"""Lookaround tests the text around a position without consuming it."""

import re

# Lookahead: match a number only where a currency code precedes... no, that is
# lookbehind. Lookahead asks about what comes AFTER the current position.
print(re.findall(r"\d+(?= EUR)", "250 EUR and 90 USD"))      # ['250']
print(re.findall(r"\d+(?! EUR)", "250 EUR and 90 USD"))      # note 25, not 250

# It consumes nothing, so two assertions can hold at the same position -- the
# usual way to say "all of these rules at once" in one pattern.
rules = re.compile(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$")
for pw in ["Sunshine1", "sunshine1", "Sun1"]:
    print(f"{pw:<10} {bool(rules.fullmatch(pw))}")

# Lookbehind asks about what comes BEFORE, and Python insists it be a KNOWN
# width, so it can step back exactly that far.
print(re.findall(r"(?<=EUR )\d+", "EUR 250"))
try:
    re.compile(r"(?<=EUR\s{1,4})\d+")
except re.error as e:
    print("variable width:", e)

# Alternatives of DIFFERENT lengths are refused for the same reason (PCRE and
# Perl allow this one; see who_supports_what).
try:
    re.compile(r"(?<=EUR|USD |GBP)\d+")
except re.error as e:
    print("uneven branches:", e)
