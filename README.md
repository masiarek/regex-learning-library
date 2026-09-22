# Regular Expressions — Learning Library

**One regular-expression question per page, put to several engines at once — and every answer backed by a program that runs, whose output is pasted in by a tool and checked in CI.**

Regular expressions are the rare topic where everyone knows the syntax and almost nobody knows the semantics. `\1`, `(?=…)` and `(?<=…)` are in every cheat sheet; what they *mean* differs between Python and JavaScript in ways that change whether your pattern is correct. This library is organised around those differences.

The languages in front are **Rust, Python and ABAP**, with **Perl, JavaScript, Ruby, Java, Go, grep and sed** brought in wherever they answer differently — which is most of the time.

## Chapters

| | |
| --- | --- |
| [Start here](00_Start_Here/README.md) | The one rule, the four engine lineages, and where to go first. |
| [Backreferences](01_Backreferences/README.md) | `\1` matches *text*, not a pattern. Four lessons: what it is, forward references, the `$1` that is not a backreference at all, and what the feature costs. |
| [Lookaround](02_Lookaround/README.md) | Zero-width assertions, the two traps everyone hits, and how wide a lookbehind may be in seven engines. |
| [Backtracking](05_Backtracking/README.md) | The patterns everybody writes that never answer, and the `(?>…)` / `a++` that fix them by changing what they match. |
| [Unicode](06_Unicode/README.md) | What `\w` and `\b` mean once the subject is not ASCII, `\p{…}` and its misspellings, and the folding table behind `(?i)`. |
| [Anchors and flags](07_Anchors/README.md) | `$` is not the end of the string, and `m` means two different things depending on which engine you ask. |
| [Match semantics](08_Match_Semantics/README.md) | Leftmost-first against leftmost-longest, greedy against lazy: one pattern, two engines, different answers, no error. |
| [Recursion and conditionals](09_Recursion/README.md) | `(?R)`, `\g<0>`, `(?(1)…)` and `(?(DEFINE)…)` — including the engines that accept the syntax while meaning something else. |
| [Engines](03_Engines/README.md) | Eleven constructs × five engines, measured by compiling each pattern. Where ABAP sits, and what to write in Rust and Go, which have no lookaround at all. |
| [Resources](04_Resources/README.md) | Official documentation per engine, books worth owning, and the sibling libraries. |

## A taste of it

The same pattern, handed to two engines, meaning two different things — from [forward references](01_Backreferences/forward_references/README.md):

```text
^(?:\1x|(a))+$      against "ax"

Perl, PCRE2, Ruby, Java, Rust (fancy-regex)   no match
JavaScript                                     match
Python                                         does not compile
```

JavaScript is not more capable there. It treats a backreference to an unset group as matching the empty string, and it clears capture groups on every iteration of a quantifier — two rules that quietly turn the pattern into something else. Nothing warns you.

## How it is checked

```bash
python3 tools/run_examples.py          # run every example, refill every page's output block
python3 tools/check_all.py             # every gate CI runs, in CI's order
uv run --group docs mkdocs serve       # preview the site
```

Ninety-two examples in Python, Perl, JavaScript, Ruby, Java, C, Go, Rust, bash, grep and sed run on every push, on Ubuntu — which is a second machine, not the one they were written on, and so a second opinion about every answer key. The fourteen ABAP examples are source-only and say so; abaplint parses them instead — see [CONTRIBUTING.md](CONTRIBUTING.md).

## Site

<https://masiarek.github.io/regex-learning-library/>
