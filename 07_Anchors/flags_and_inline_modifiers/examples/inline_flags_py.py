#!/usr/bin/env python3
"""Python's flag letters, and how far an inline (?i) reaches.

Nothing here prints a version, a path, or an engine's error text, so Python 3.12
and Python 3.14 produce byte-identical output. A compile failure is reported as
the fixed word `compile error`, because the wording of re.error changes between
releases and the fact of the refusal does not.
"""

import re

THREE = "one" + chr(10) + "two" + chr(10) + "three"
CRLF = "abc" + chr(13) + chr(10) + "def"


def esc(s):
    """Show a subject with its line structure visible, never raw."""
    body = s.replace("\\", "\\\\").replace(chr(10), "\\n").replace(chr(13), "\\r")
    return '"' + body + '"'


def show(label, pattern, subject, flags=0):
    try:
        m = re.search(pattern, subject, flags)
    except re.error:
        print("  %-30s compile error" % label)
        return
    print("  %-30s %s" % (label, "match " + esc(m.group(0)) if m else "no match"))


print("== the dot: what it excludes ==")
print("subject " + esc("one" + chr(10) + "two"))
show("one.two", "one.two", "one\ntwo")
show("one.two  re.DOTALL", "one.two", "one\ntwo", re.DOTALL)
show("(?s)one.two", "(?s)one.two", "one\ntwo")
print("subject " + esc("one" + chr(13) + "two"))
show("one.two", "one.two", "one\rtwo")

print("== the letter m: line anchors ==")
print("subject " + esc(THREE))
show("^two$", "^two$", THREE)
show("^two$  re.MULTILINE", "^two$", THREE, re.MULTILINE)
show("(?m)^two$", "(?m)^two$", THREE)
show("one.two  re.MULTILINE", "one.two", THREE, re.MULTILINE)
print("subject " + esc(CRLF))
show("^abc$  re.MULTILINE", "^abc$", CRLF, re.MULTILINE)
show("^abc\\r?$  re.MULTILINE", "^abc\r?$", CRLF, re.MULTILINE)

print("== free-spacing: re.VERBOSE ==")
UGLY = r"(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])"
TIDY = r"""
    (\d{4})                 # year
    -
    (0[1-9] | 1[0-2])       # month, 01-12
    -
    (0[1-9] | [12]\d | 3[01])   # day, 01-31
"""
show("one line", UGLY, "due 2026-09-22 ok")
show("re.VERBOSE", TIDY, "due 2026-09-22 ok", re.VERBOSE)
show("a b   on " + esc("a b"), "a b", "a b", re.VERBOSE)
show("a b   on " + esc("ab"), "a b", "ab", re.VERBOSE)
show("a\\ b  on " + esc("a b"), r"a\ b", "a b", re.VERBOSE)
show("[ ]   on " + esc("a b"), "a[ ]b", "a b", re.VERBOSE)
show("a#b   on " + esc("a#b"), "a#b", "a#b", re.VERBOSE)

print("== inline and scoped modifiers ==")
show("abc          on ABC", "abc", "ABC")
show("abc   re.I   on ABC", "abc", "ABC", re.I)
show("(?i)abc      on ABC", "(?i)abc", "ABC")
show("(?i:b)c      on Bc", "(?i:b)c", "Bc")
show("(?i:b)c      on bC", "(?i:b)c", "bC")
show("(?i)ab(?-i:cd) on ABcd", "(?i)ab(?-i:cd)", "ABcd")
show("(?i)ab(?-i:cd) on ABCD", "(?i)ab(?-i:cd)", "ABCD")
show("a(?i)bc      on aBC", "a(?i)bc", "aBC")
show("(a(?i)b)c    on aBc", "(a(?i)b)c", "aBc")
show("(a(?i)b)c    on abC", "(a(?i)b)c", "abC")
