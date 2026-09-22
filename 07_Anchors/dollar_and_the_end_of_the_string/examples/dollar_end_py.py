"""`$` in Python is "end of string, OR just before a newline at the end of it".

Three subjects, printed escaped because one of them contains a newline and a
page must show where the line ends:

    "1"             what a validator expects
    "1\\n"           the same value out of a form field or a file read
    "1\\nrm -rf /"   a second line the validator was never shown
"""

import re

SUBJECTS = [("1", '"1"'), ("1\n", r'"1\n"'), ("1\nrm -rf /", r'"1\nrm -rf /"')]


def row(label, a, b, c):
    print(f"{label:<30}{a:<8}{b:<8}{c}")


def verdicts(fn):
    return [("match" if fn(s) else "no") for s, _ in SUBJECTS]


print("python re")
row("pattern", *[shown for _, shown in SUBJECTS])
row(r'search(r"^\d+$")', *verdicts(lambda s: re.search(r"^\d+$", s)))
row(r'search(r"\A\d+\Z")', *verdicts(lambda s: re.search(r"\A\d+\Z", s)))
row(r'search(r"(?m)^\d+$")', *verdicts(lambda s: re.search(r"(?m)^\d+$", s)))
row(r'fullmatch(r"\d+")', *verdicts(lambda s: re.fullmatch(r"\d+", s)))

# Where the match actually stopped. `$` asserted a position that is not the end
# of the string, so the newline is still in the value the caller goes on to use.
m = re.search(r"^\d+$", "1\n")
print()
print(r'^\d+$ on "1\n" matched', repr(m.group()), "and ended at offset", m.end(),
      "of", len("1\n"))

# The flag letters. In Python, M is the line-anchor flag and S is the dot flag;
# they are separate, and neither is on by default.
print()
row("flag", "off", "re.M", "re.S")
row(r'^\d+$ on "1\nrm -rf /"',
    "match" if re.search(r"^\d+$", "1\nrm -rf /") else "no",
    "match" if re.search(r"^\d+$", "1\nrm -rf /", re.M) else "no",
    "match" if re.search(r"^\d+$", "1\nrm -rf /", re.S) else "no")
row(r'a.b on "a\nb"',
    "match" if re.search(r"a.b", "a\nb") else "no",
    "match" if re.search(r"a.b", "a\nb", re.M) else "no",
    "match" if re.search(r"a.b", "a\nb", re.S) else "no")

# `\A` is what `^` stops being once the line flag is on. Put the payload first
# and the digits last, and the two anchors part company. `(?-m:...)` cancels
# the flag again -- Python only takes a negated inline flag in the scoped form,
# so a bare `(?-m)` is a compile error here, and in Ruby the same letter means
# the dot flag instead. Three engines, three answers to one spelling.
print()
print(r'with re.M, on "rm -rf /\n1":')
for pattern in (r"^\d+$", r"\A\d+$", r"(?-m:^\d+$)"):
    hit = re.search(pattern, "rm -rf /\n1", re.M)
    print(f"  {pattern:<28}{'match' if hit else 'no'}")
