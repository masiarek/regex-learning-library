"""Greedy and lazy in Python's `re`: the same pattern, one character of difference.

Nothing here times anything. The question on this page is which match is found,
not how fast -- the cost is measured in greedy_lazy_java.java.
"""

import re

subject = "<b>bold</b>"

# The canonical demonstration. `.+` takes everything it can and gives back until
# the final `>` fits, which leaves the LAST `>` in the match. `.+?` takes one
# character and asks for more only when `>` does not fit yet, so it stops at the
# FIRST `>`.
print("subject      ", subject)
for pattern in (r"<.+>", r"<.+?>", r"<[^>]+>"):
    print(f"  {pattern:<9} first match {re.search(pattern, subject).group()!r}")

# The same difference, seen from the other end: what a global search returns.
for pattern in (r"<.+>", r"<.+?>", r"<[^>]+>"):
    print(f"  {pattern:<9} findall     {re.findall(pattern, subject)}")

# ...and what a substitution deletes. The greedy one eats the text between the
# tags, which is the classic strip-the-tags bug.
for pattern in (r"<.+>", r"<.+?>", r"<[^>]+>"):
    print(f"  {pattern:<9} sub to ''   {re.sub(pattern, '', subject)!r}")

# The same question with no delimiters in sight, so the four spellings can be
# compared with the other engines on the page.
print("subject      ", "aaa")
for pattern in (r"a+", r"a+?", r"a*?", r"a{1,3}?"):
    print(f"  {pattern:<9} first match {re.search(pattern, 'aaa').group()!r}")

# Where laziness changes the ANSWER, not the speed: which delimiter closes the
# capture. Greedy runs to the last quote on the line; lazy stops at the first.
line = 'name="ada", role="pilot"'
print("subject      ", line)
for pattern in (r'"(.*)"', r'"(.*?)"', r'"([^"]*)"'):
    print(f"  {pattern:<9} group 1     {re.search(pattern, line).group(1)!r}")

# Where laziness changes nothing at all. A lazy quantifier at the END of a
# pattern has nothing left to satisfy, so it stops immediately: it matches the
# empty string and the `?` has bought a longer pattern and no new behaviour.
print("subject      ", line)
print(f"  {'name=.*':<9} match       {re.search(r'name=.*', line).group()!r}")
print(f"  {'name=.*?':<9} match       {re.search(r'name=.*?', line).group()!r}")

# Anchor it and the two agree again -- `$` forces the lazy one to take the whole
# rest of the line one character at a time to reach the end it must reach.
print(f"  {'name=.*$':<9} match       {re.search(r'name=.*$', line).group()!r}")
print(f"  {'name=.*?$':<9} match       {re.search(r'name=.*?$', line).group()!r}")
