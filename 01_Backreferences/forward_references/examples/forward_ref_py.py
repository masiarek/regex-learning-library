"""A forward reference is \\1 written BEFORE group 1 is defined."""

import re

# Python refuses it when the pattern is compiled, before any subject exists.
try:
    re.compile(r"^(?:\1x|(a))+$")
except re.error as e:
    print("python compile:", e)

# The rule is about the reference, not the repetition: Python is equally firm
# about the textbook example, where the group IS defined later in the pattern.
try:
    re.compile(r"(\2two|(one))+")
except re.error as e:
    print("python compile:", e)

# Written the other way round -- group first, reference after -- it is an
# ordinary backreference and Python is happy.
print("backwards is fine:", re.fullmatch(r"^(?:(a)|\1x)+$", "aax") is not None)
