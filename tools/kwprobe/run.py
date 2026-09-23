#!/usr/bin/env python3
r"""Put the same rows to eight engines and print one table.

This is the program behind every generated block on a Keywords or Topics page.
A row names a construct, a pattern and (usually) a subject; each engine is
asked the same three-part question -- does it compile, does it match, and
what exactly did it match -- and answers with one cell. Nothing on those
pages is transcribed from documentation: if a cell says `yes`, an engine said
so a moment before the page was filled.

    python3 tools/kwprobe/run.py <<'ROWS'
    # label            :: pattern     :: subject   [:: option ...]
    plain backreference :: (a)\1      :: xaay
    compile only        :: (?>a+)
    replacement         :: (a)(b)     :: ab        :: replace=$2$1
    split with capture  :: (,)        :: a,b       :: split
    ROWS

Rows
----
Fields are separated by ` :: ` (space, two colons, space), so `|` and `:`
are free for the pattern. Blank lines and `#` comments are skipped.

    label    what the row is called in the table
    pattern  handed to each engine verbatim -- escapes in it are the engine's
             business, and that is often the point of the row
    subject  optional; `\n` `\r` `\t` `\\` and `\u{HEX}` are decoded the same
             way by every probe, so a row can hold a newline or a non-ASCII
             character without the file containing one

Options, any number, after the subject:

    replace=TMPL   replace the FIRST match with TMPL and show the result. TMPL
                   is handed to each engine's own replacement language
                   unchanged, which is how `$1` against `\1` gets measured
    split          split the subject on the pattern; the cell is the pieces
                   in brackets, `[a,b,c]`, an empty piece showing as nothing
    node=FLAGS     JavaScript has no inline flags, so `u`, `s`, `i` and the
                   rest arrive here for that column only
    skip=a,b       leave these engines out of the row (`n/a`) -- for a
                   construct whose answer would depend on a runtime version
                   that differs between the author's machine and CI

Cells
-----
    -        the engine refused to compile the pattern
    no       compiled, and did not match the subject
    ""       matched the empty string
    text     the text matched (or produced), escaped back to pure ASCII
    ok       compiled; the row had no subject
    err      compiled, then failed at match time -- a backtrack limit, or a
             replacement template the engine rejected
    n/a      skipped for this engine

Engines
-------
python  `python3.12` if it is on PATH, else `python3`. CI's runner is 3.12
        and the author's machine has 3.14 beside it; preferring the older one
        means a key cannot pass here and fail there. (3.14 changed answers:
        it added `\z`.) A row where the two differ is a finding for a page's
        prose, not for a key.
perl    perl 5.36+
node    node -- no syntax newer than ES2018 goes in a row, because node 20
        here and node 24 in CI disagree about newer regexp syntax
ruby    the newest ruby the runner finds (macOS ships 2.6 as /usr/bin/ruby)
java    java 25
go      Go's regexp (RE2)
rust    the `regex` crate, and `fancy`, the `fancy-regex` crate, from the
        rust-demo/ workspace with --locked

Every probe is a separate program in this folder, one per engine, so the
Rust column can be verified in a Rust container and the Ruby column in a
Ruby one without the rest.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
COLUMNS = ["python", "perl", "node", "ruby", "java", "go", "rust", "fancy"]


def _ruby() -> str:
    for cand in (os.environ.get("RUBY", ""), "/usr/local/opt/ruby/bin/ruby",
                 "/opt/homebrew/opt/ruby/bin/ruby", shutil.which("ruby") or ""):
        if cand and Path(cand).exists():
            return cand
    sys.exit("kwprobe: no ruby found")


def _python() -> str:
    return os.environ.get("PY") or shutil.which("python3.12") or sys.executable


def commands(rows: str) -> dict[str, list[str]]:
    java = os.environ.get("JAVA") or shutil.which("java") or "java"
    return {
        "python": [_python(), "-I", str(HERE / "probe.py"), rows],
        "perl": [os.environ.get("PERL") or "perl", str(HERE / "probe.pl"), rows],
        "node": [os.environ.get("NODE") or "node", str(HERE / "probe.js"), rows],
        "ruby": [_ruby(), "-W0", str(HERE / "probe.rb"), rows],
        "java": [java, str(HERE / "Probe.java"), rows],
        "go": [os.environ.get("GO") or "go", "run", str(HERE / "probe.go"), rows],
        # One binary, two columns: `regex` and `fancy-regex`, tab-separated.
        "rust": ["cargo", "run", "--locked", "--quiet",
                 "--manifest-path", str(REPO / "rust-demo" / "Cargo.toml"),
                 "--bin", "kwprobe", "--", rows],
    }


def labels(text: str) -> list[str]:
    out = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        out.append(line.split(" :: ")[0].strip())
    return out


def run(cmd: list[str], expect: int) -> list[str]:
    done = subprocess.run(cmd, capture_output=True, text=True)
    if done.returncode != 0:
        sys.exit(f"kwprobe: {cmd[0]} failed\n{done.stderr}")
    lines = done.stdout.rstrip("\n").split("\n") if done.stdout.strip() else []
    if len(lines) != expect:
        sys.exit(f"kwprobe: {cmd[0]} printed {len(lines)} lines for {expect} rows\n{done.stdout}")
    return lines


def main() -> int:
    text = sys.stdin.read()
    names = labels(text)
    if not names:
        sys.exit("kwprobe: no rows on stdin")
    with tempfile.NamedTemporaryFile("w", suffix=".rows", delete=False, encoding="utf-8") as fh:
        fh.write(text)
        rows = fh.name
    try:
        cells: dict[str, list[str]] = {}
        for engine, cmd in commands(rows).items():
            lines = run(cmd, len(names))
            if engine == "rust":
                pairs = [ln.split("\t") for ln in lines]
                cells["rust"] = [p[0] for p in pairs]
                cells["fancy"] = [p[1] if len(p) > 1 else "?" for p in pairs]
            else:
                cells[engine] = lines
    finally:
        os.unlink(rows)

    head = ["construct"] + COLUMNS
    table = [head] + [[names[i]] + [cells[c][i] for c in COLUMNS] for i in range(len(names))]
    widths = [max(len(r[j]) for r in table) for j in range(len(head))]
    for r in table:
        print("  ".join(cell.ljust(widths[j]) for j, cell in enumerate(r)).rstrip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
