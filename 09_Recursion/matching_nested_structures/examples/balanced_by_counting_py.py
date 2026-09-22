"""The portable answer: count the depth in the host language.

Python's `re` has no recursion in any spelling, so this file also shows what it
does with the two dialects -- and then does the job with one counter and one
pass, in a shape that works in every language on the page, needs no engine
feature, and says *where* the input went wrong instead of only that it did.
"""

import re


def scan(text):
    """Report the first balanced parenthesised group in `text`, or what broke."""
    depth = 0
    start = None
    for offset, char in enumerate(text):
        if char == "(":
            if depth == 0:
                start = offset
            depth += 1
        elif char == ")":
            if depth == 0:
                return f"unexpected ')' at offset {offset}"
            depth -= 1
            if depth == 0:
                return f"balanced, offsets {start}..{offset}"
    if depth:
        return f"{depth} unclosed '(', outermost at offset {start}"
    return "no parentheses"


SUBJECTS = ["(a(b)c)", "((a)(b))", "()", "(a(b)c", "a)b", "a"]

print("what Python's re does with a recursive pattern")
for label, pattern in [
    ("(?R)", r"\((?:[^()]|(?R))*\)"),
    ("(?1)", r"(\((?:[^()]|(?1))*\))"),
    ("(?&p)", r"(?P<p>\((?:[^()]|(?&p))*\))"),
    (r"\g<0>", r"\((?:[^()]|\g<0>)*\)"),
]:
    try:
        re.compile(pattern)
        outcome = "compiled"
    except re.error:
        outcome = "refused at compile time"
    print(f"  {label:<8} {outcome}")

print("\ncounting instead")
for subject in SUBJECTS:
    print(f"  {subject:<10} {scan(subject)}")

print("\nno engine limit applies: depth is just an integer")
for depth in (10, 1000, 100_000):
    print(f"  depth {depth:<7} {scan('(' * depth + 'a' + ')' * depth)}")

print("\nand hostile input is answered in one pass, not searched")
print(f"  {'(' * 40:.12}...  {scan('(' * 40)}")
