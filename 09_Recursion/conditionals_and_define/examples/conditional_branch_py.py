"""Python's `re` HAS conditionals -- and one spelling of them, not PCRE's.

Everything printed is a fixed label chosen here, never an engine's own error
text: Python renamed `re.error` to `re.PatternError` and reworded several of
these messages between 3.12 and 3.14, so a key that quoted them would not
survive the trip from this machine to CI.
"""

import re

SUBJECTS = ("<tag>", "tag", "<tag")


def row(label: str, pattern: str) -> None:
    """Compile, then report yes/no for each subject -- or one word if it refused."""
    try:
        rx = re.compile(pattern)
    except re.error:
        print(f"{label:<30} compile error")
        return
    cells = "".join(f"{'yes' if rx.fullmatch(s) else 'no':<7}" for s in SUBJECTS)
    print(f"{label:<30} {cells}".rstrip())


print(f"{'':<30} {'<tag>':<7}{'tag':<7}{'<tag':<7}".rstrip())

# The classic honest use: an optional opening delimiter that makes the closing
# one mandatory. Group 1 participated => the yes-branch requires '>'.
row("numbered   (?(1)>)", r"^(<)?\w+(?(1)>)$")

# Python's named form names the group bare, with no angle brackets, and the
# group itself must be written Python's way: (?P<open>...).
row("named      (?(open)>)", r"^(?P<open><)?\w+(?(open)>)$")

# The spellings Perl and PCRE2 use, handed to Python unchanged.
row("PCRE named (?(<open>)>)", r"^(?<open><)?\w+(?(<open>)>)$")
row("lookaround (?(?=<)<\\w+>|\\w+)", r"^(?(?=<)<\w+>|\w+)$")
row("DEFINE     (?(DEFINE)...)", r"(?(DEFINE)(?P<octet>\d))^(?P>octet)$")

# A condition naming a group that does not exist.
row("no such group (a)(?(2)x|y)", r"^(a)(?(2)x|y)$")

print()
print("then someone adds an optional numeric prefix in front of it:")

# One new group at the front, and (?(1)...) now tests the PREFIX. Every answer
# above inverts -- and the pattern starts accepting the string it existed to
# reject.
row("numbered   (?(1)>)", r"^(?:(\d+):)?(<)?\w+(?(1)>)$")
row("named      (?(open)>)", r"^(?:(\d+):)?(?P<open><)?\w+(?(open)>)$")
