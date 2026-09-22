#!/usr/bin/env python3
"""Where the cliff is, measured without a stopwatch.

A timing is not a fact two machines agree on, so this program records none.
Every probe runs in a **child process** with a fixed cap, and the answer key
holds one of three words: `match`, `no match`, or `no answer`. The two subject
sizes are chosen far either side of the cliff on purpose -- the small one costs
a few thousand steps, the large one more steps than a machine will ever take --
so a slow runner and a fast one record the same table.

Nothing here contains a backreference. Every pattern is one somebody wrote on
purpose, believing it was a validator.
"""

import subprocess
import sys

CAP = 3  # seconds before the child is killed

EMAIL = r"^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z]{2,4})+$"
EMAIL_FIXED = r"^[a-zA-Z0-9_.-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4}$"

SMALL = "a" * 16 + "!"
GOOD = "a" * 120                     # this one MATCHES, and that is the point
HOSTILE = "a" * 120 + "!"            # one character that cannot match
BLANKS = " " * 120 + "!"
MAIL_SMALL = "a@a." + "a" * 20 + "!"
MAIL_HOSTILE = "a@a." + "a" * 120 + "!"


def probe(pattern, subject):
    """Run one match in a child process; report what came back, not how long it took."""
    code = "import re\nprint(bool(re.match(%r, %r)))" % (pattern, subject)
    try:
        done = subprocess.run(
            [sys.executable, "-I", "-c", code],
            capture_output=True, text=True, timeout=CAP,
        )
    except subprocess.TimeoutExpired:
        return "no answer"
    if done.returncode != 0:
        return "error"
    return {"True": "match", "False": "no match"}[done.stdout.strip()]


def table(title, rows):
    print(title)
    for pattern, shown, subject, described in rows:
        print("  %-24s %-22s %s" % (shown or pattern, described, probe(pattern, subject)))


print('"no answer" means the child was still searching after %d seconds and was killed.' % CAP)
print()

table("patterns with no backreference, python re:", [
    (r"^(a+)+$", None, SMALL, "16 a's then '!'"),
    (r"^(a+)+$", None, GOOD, "120 a's"),
    (r"^(a+)+$", None, HOSTILE, "120 a's then '!'"),
    (r"^(a|a)*$", None, HOSTILE, "120 a's then '!'"),
    (r"^(\s*|\t)+$", None, BLANKS, "120 spaces then '!'"),
    (r"^(\w+\s?)*$", None, HOSTILE, "120 a's then '!'"),
    (r"^([a-z]{2,4})+$", None, HOSTILE, "120 a's then '!'"),
    (EMAIL, "the email regex", MAIL_SMALL, "a@a. 20 a's then '!'"),
    (EMAIL, "the email regex", MAIL_HOSTILE, "a@a. 120 a's then '!'"),
])

print()
table("the same engine, with the pattern changed instead:", [
    (r"^(?>a+)+$", None, HOSTILE, "120 a's then '!'"),
    (r"^(a++)+$", None, HOSTILE, "120 a's then '!'"),
    (r"^a+$", None, HOSTILE, "120 a's then '!'"),
    (EMAIL_FIXED, "the email regex, fixed", MAIL_HOSTILE, "a@a. 120 a's then '!'"),
])
