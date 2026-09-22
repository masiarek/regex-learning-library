"""Where atomic groups pay: cutting an exponential search dead.

No timings are printed, because a timing is not reproducible. Each question is
asked in a CHILD process with a hard cap, and the answer recorded is one of
three words: a match, no match, or the engine was still working when the cap
expired. The two subject sizes are chosen far either side of the cliff, so every
machine that has ever run this agrees on which cell says what:

    16 a's is a few thousand steps -- microseconds on anything.
    40 a's is 2**40 -- over a day, on anything.
"""

import subprocess
import sys

CAP = 5  # seconds a child gets before it is killed

# Run in a child so an unbounded search can be stopped. re is the only import.
CHILD = "import re, sys; print(bool(re.search(sys.argv[1], sys.argv[2])))"

PATTERNS = [r"^(a+)+$", r"^(?>a+)+$", r"^(a++)+$"]


def ask(pattern: str, subject: str) -> str:
    """The child's verdict, or the fact that it never reached one."""
    try:
        done = subprocess.run(
            [sys.executable, "-I", "-c", CHILD, pattern, subject],
            capture_output=True, text=True, timeout=CAP,
        )
    except subprocess.TimeoutExpired:
        return f"no answer in {CAP}s"
    return "match" if done.stdout.strip() == "True" else "no match"


print("subject: n copies of 'a' and then '!', which nothing here can match --")
print("the engine has to PROVE it, and that is the expensive direction.")
print(f"{'pattern':<12} {'n=16':<16} n=40")
for pattern in PATTERNS:
    cells = [ask(pattern, "a" * n + "!") for n in (16, 40)]
    print(f"{pattern:<12} {cells[0]:<16} {cells[1]}")

print()
print("subject: n copies of 'a' and nothing else -- all three still match it,")
print("so cutting the backtracking did not cost a single true answer.")
print(f"{'pattern':<12} {'n=16':<16} n=40")
for pattern in PATTERNS:
    cells = [ask(pattern, "a" * n) for n in (16, 40)]
    print(f"{pattern:<12} {cells[0]:<16} {cells[1]}")
