"""The other \\1: in a REPLACEMENT it is not a backreference at all."""

import re

iban = "DE44 5001 0517 5407 3249 31"

# In the replacement, \1 means "insert what group 1 captured". It is an
# instruction to the substituter, not a pattern the engine matches.
print(re.sub(r"(\d{4}) (\d{4})", r"\1-\2", iban))

# \g<1> is the same, and it is the spelling that survives a digit after it.
print(re.sub(r"(\d{4})", r"\g<1>0", "1234"))       # 12340
# print(re.sub(r"(\d{4})", r"\10", "1234"))        # error: group 10

# \g<0> is the whole match, and \g<name> reads better than a number.
print(re.sub(r"(?P<y>\d{4})-(?P<m>\d{2})", r"\g<m>/\g<y>", "2026-09"))
print(re.sub(r"\d+", r"[\g<0>]", "order 42"))

# $1 is JavaScript, Perl and ABAP; in Python it is three literal characters.
print(re.sub(r"(\d+)", r"$1", "order 42"))
