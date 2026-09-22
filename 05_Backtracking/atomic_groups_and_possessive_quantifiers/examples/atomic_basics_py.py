"""(?>a+) and a++ are one feature with two spellings -- and it changes the RESULT.

Python's re has had both since 3.11. Everything below is a match or a non-match,
not a stopwatch: the point of this file is that switching a quantifier to its
possessive form can change what a pattern accepts.
"""

import re


def ask(pattern: str, subject: str) -> None:
    """Print what `pattern` finds in `subject`, or that it finds nothing."""
    found = re.search(pattern, subject)
    answer = repr(found.group(0)) if found else "no match"
    print(f"  {pattern:<21} on {subject!r:<15} -> {answer}")


print("1. a++ is exactly (?>a+): greedy, and then never gives a character back")
ask(r"a+a", "aa")        # the + hands one 'a' back so the trailing a can match
ask(r"a++a", "aa")       # nothing to hand back: no match, at any position
ask(r"(?>a+)a", "aa")    # the same pattern, spelled as an atomic group
ask(r"a+b", "aab")       # b is not a, so there is nothing to give back anyway
ask(r"a++b", "aab")
ask(r"(?>a+)b", "aab")

print("2. and they agree on every subject, not just these")
subjects = ["", "a", "aa", "aaa", "ab", "aab", "ba", "aaab"]
atomic = [bool(re.search(r"(?>a+)b", s)) for s in subjects]
possessive = [bool(re.search(r"a++b", s)) for s in subjects]
print(f"  (?>a+)b and a++b answer alike on {len(subjects)} subjects: {atomic == possessive}")

print("3. the 'optimisation' that silently stops matching")
# A possessive quantifier over a class that OVERLAPS what follows it is a bug.
# [\w.] can match the dot and the letters of '.com', so once it has eaten them
# possessively there is nothing left for \.com, and no way to get it back.
ask(r"^[\w.]+\.com$", "example.com")
ask(r"^[\w.]++\.com$", "example.com")

print("4. and the one that is free, because the class cannot overlap")
# \d can never match '.', so the + had no useful backtracking position to lose.
ask(r"^\d+\.\d+$", "3.14")
ask(r"^\d++\.\d+$", "3.14")

print("5. the lookahead-and-backreference emulation, which needs neither feature")
# (?=(X))\1 captures X in a lookahead and then re-consumes exactly that text.
# A lookahead never backtracks into its own alternatives once it has succeeded,
# so the captured run is fixed -- an atomic group built from two other features.
ask(r"(?=(a+))\1a", "aaa")
ask(r"(?=(a+))\1b", "aab")
ask(r"^(?=([\w.]+))\1\.com$", "example.com")
