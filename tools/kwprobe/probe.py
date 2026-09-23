"""The Python column of tools/kwprobe/run.py. One cell per row on stdout."""

import re
import sys


def decode(s: str) -> str:
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            n = s[i + 1]
            if n == "n":
                out.append("\n"); i += 2; continue
            if n == "r":
                out.append("\r"); i += 2; continue
            if n == "t":
                out.append("\t"); i += 2; continue
            if n == "\\":
                out.append("\\"); i += 2; continue
            if n == "u" and i + 2 < len(s) and s[i + 2] == "{":
                j = s.index("}", i)
                out.append(chr(int(s[i + 3:j], 16))); i = j + 1; continue
        out.append(c); i += 1
    return "".join(out)


def encode(s: str) -> str:
    if s == "":
        return '""'
    out = []
    for c in s:
        if c == "\\":
            out.append("\\\\")
        elif c == "\n":
            out.append("\\n")
        elif c == "\r":
            out.append("\\r")
        elif c == "\t":
            out.append("\\t")
        elif ord(c) < 0x20 or ord(c) > 0x7E:
            out.append("\\u{%X}" % ord(c))
        else:
            out.append(c)
    return "".join(out)


def cell(fields: list[str]) -> str:
    pattern = fields[1]
    subject = decode(fields[2]) if len(fields) > 2 else None
    opts = fields[3:]
    replace = split = None
    for o in opts:
        if o.startswith("replace="):
            replace = decode(o[8:])
        elif o == "split":
            split = True
        elif o.startswith("skip=") and "python" in o[5:].split(","):
            return "n/a"
    try:
        rx = re.compile(pattern)
    except Exception:
        return "-"
    if subject is None:
        return "ok"
    try:
        if replace is not None:
            if rx.search(subject) is None:
                return "no"
            return encode(rx.sub(replace, subject, count=1))
        if split:
            return "[" + ",".join(encode(p) if p else "" for p in rx.split(subject)) + "]"
        m = rx.search(subject)
        return "no" if m is None else encode(m.group(0))
    except Exception:
        return "err"


def main() -> None:
    for line in open(sys.argv[1], encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        fields = [f.strip() for f in line.split(" :: ")]
        print(cell(fields))


main()
