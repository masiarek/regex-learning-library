# Start here

**One line:** This library answers regular-expression questions by running them — in Rust, Python and ABAP first, then Perl, JavaScript, Ruby, Java, Go, grep and sed — because the interesting part of a regular expression is almost always where the engines disagree.

## The one rule

A page never claims something a program has not printed. Every output block on every lesson is pasted in by `tools/run_examples.py` from a real run, and CI fails if a page and its program drift apart. When you read `['25', '90']` on the [lookaround page](../02_Lookaround/lookahead_and_lookbehind/README.md), that is what Python printed, not what the author remembered.

There is one exception, and it is marked: **ABAP**. Nothing here — and nothing on a GitHub runner — has an ABAP system, so `.abap` files are pasted as source and never carry an answer key. Where the engine underneath ABAP can be shown, it is shown honestly, as a dated transcript from PCRE2 on the machine that wrote the page.

## Where to go

| If you want | Go to |
| --- | --- |
| What one piece of syntax means, per engine — `\b`, `(?>…)`, `$1`, `\K` | [Keywords](../10_Keywords/README.md), one page per construct, each with an eight-engine table |
| How to do a job — validate a field, split a line, port a pattern | [Topics](../11_Topics/README.md), one page per job |
| The thing `\1` actually means | [What a backreference is](../01_Backreferences/what_a_backreference_is/README.md) |
| `\1` written before its group — and the names people confuse it with | [Forward references](../01_Backreferences/forward_references/README.md) |
| Why `$1` and `\1` are not the same feature | [Backreferences in the replacement](../01_Backreferences/backreferences_in_the_replacement/README.md) |
| Why Go and Rust refuse backreferences | [What a backreference costs](../01_Backreferences/what_a_backreference_costs/README.md) |
| `(?=…)`, `(?<=…)`, and how wide a lookbehind may be | [Lookahead and lookbehind](../02_Lookaround/lookahead_and_lookbehind/README.md) |
| A table of which engine has which construct | [Who supports what](../03_Engines/who_supports_what/README.md) |
| Books and the official documentation | [Resources](../04_Resources/README.md) |

## Where to go when something is already wrong

Most of this library exists because a pattern that looks right is not, and the failure is a match result rather than an error message. If one of these is your afternoon, start here instead of at the beginning:

| The symptom | The page |
| --- | --- |
| A request hangs; a pattern is fast on test data and not in production | [Catastrophic backtracking](../05_Backtracking/catastrophic_backtracking/README.md) |
| Somebody made a pattern faster and it stopped matching | [Atomic groups and possessive quantifiers](../05_Backtracking/atomic_groups_and_possessive_quantifiers/README.md) |
| A validator rejects somebody's name, or accepts a "number" the language cannot parse | [What `\w` and `\b` match](../06_Unicode/what_w_and_b_match/README.md) |
| `\p{L}` does nothing, or works in one language and not the next | [Naming a Unicode property](../06_Unicode/unicode_properties/README.md) |
| `(?i)` matched something you did not expect it to | [`(?i)` is a folding table](../06_Unicode/case_insensitive_matching/README.md) |
| `^…$` let something through that it should not have | [`$` is not the end of the string](../07_Anchors/dollar_and_the_end_of_the_string/README.md) |
| The same flag letter means something else in the other language | [Flags, and where you can turn one on](../07_Anchors/flags_and_inline_modifiers/README.md) |
| The pattern matches in both engines and hands back different text | [Leftmost-first and leftmost-longest](../08_Match_Semantics/leftmost_first_vs_leftmost_longest/README.md) |
| Someone told you `.*?` is the fast one | [Greedy and lazy](../08_Match_Semantics/greedy_and_lazy/README.md) |
| You are about to match something nested | [Matching nested structures](../09_Recursion/matching_nested_structures/README.md) |
| One pattern has to handle an optional delimiter properly | [Conditionals and `(?(DEFINE)…)`](../09_Recursion/conditionals_and_define/README.md) |

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
