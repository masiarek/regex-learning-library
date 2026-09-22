# Start here

**One line:** This library answers regular-expression questions by running them — in Rust, Python and ABAP first, then Perl, JavaScript, Ruby, Java, Go, grep and sed — because the interesting part of a regular expression is almost always where the engines disagree.

## The one rule

A page never claims something a program has not printed. Every output block on every lesson is pasted in by `tools/run_examples.py` from a real run, and CI fails if a page and its program drift apart. When you read `['25', '90']` on the [lookaround page](../02_Lookaround/lookahead_and_lookbehind/README.md), that is what Python printed, not what the author remembered.

There is one exception, and it is marked: **ABAP**. Nothing here — and nothing on a GitHub runner — has an ABAP system, so `.abap` files are pasted as source and never carry an answer key. Where the engine underneath ABAP can be shown, it is shown honestly, as a dated transcript from PCRE2 on the machine that wrote the page.

## Where to go

| If you want | Go to |
| --- | --- |
| The thing `\1` actually means | [What a backreference is](../01_Backreferences/what_a_backreference_is/README.md) |
| `\1` written before its group — and the names people confuse it with | [Forward references](../01_Backreferences/forward_references/README.md) |
| Why `$1` and `\1` are not the same feature | [Backreferences in the replacement](../01_Backreferences/backreferences_in_the_replacement/README.md) |
| Why Go and Rust refuse backreferences | [What a backreference costs](../01_Backreferences/what_a_backreference_costs/README.md) |
| `(?=…)`, `(?<=…)`, and how wide a lookbehind may be | [Lookahead and lookbehind](../02_Lookaround/lookahead_and_lookbehind/README.md) |
| A table of which engine has which construct | [Who supports what](../03_Engines/who_supports_what/README.md) |
| Books and the official documentation | [Resources](../04_Resources/README.md) |

## The four lineages

Nearly every engine you will meet is one of four, and knowing which one you are holding predicts more than any single fact:

- **Perl / PCRE2** — the biggest feature set. Perl, PCRE2, PHP, and **ABAP's `PCRE` addition** since release 7.55.
- **The middle ground** — Java, Ruby, JavaScript, C#. Perl-like, each missing a different corner.
- **Python `re`** — Perl-like, stricter about lookbehind width and forward references.
- **Automata** — Go's `regexp`, Rust's `regex`, RE2. No backreferences, no lookaround, and a guarantee of linear time in exchange.

## Running it yourself

```bash
python3 tools/run_examples.py          # run every example, refill every page
python3 tools/check_all.py             # everything CI runs, in CI's order
uv run --group docs mkdocs serve       # preview the site locally
```

The Rust answers need a crate, because Rust has no regular expressions in its standard library; they run through the small Cargo workspace in `rust-demo/` from a `.sh` example. Everything else uses the language's own standard library.
