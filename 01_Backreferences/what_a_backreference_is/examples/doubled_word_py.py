"""A backreference matches the TEXT a group captured, not the pattern again."""

import re

text = "the the quick brown fox fox jumped over the lazy dog dog"

# \1 is "whatever group 1 matched, character for character".
for m in re.finditer(r"\b(\w+) \1\b", text):
    print(f"numbered   offset {m.start():>2}  {m.group()!r}  group 1 = {m.group(1)!r}")

# The same rule with a name, which survives someone inserting a group above it.
for m in re.finditer(r"\b(?P<word>\w+) (?P=word)\b", text):
    print(f"named      offset {m.start():>2}  {m.group()!r}")

# It is the text, not the pattern: \1 after (\w+) does not mean "another word".
print("two different words:", re.search(r"\b(\w+) \1\b", "the quick") is not None)

# A backreference to a group that did not take part fails the match here --
# it does not quietly match the empty string. (JavaScript disagrees; see the
# forward_references lesson.)
print("unset group:        ", re.fullmatch(r"(z)?\1", "") is not None)
