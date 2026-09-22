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

Twenty-three examples in Python, Perl, JavaScript, Go, Rust, bash, grep and sed run on every push. The ABAP examples are source-only and say so — see [CONTRIBUTING.md](CONTRIBUTING.md).

## Site

<https://masiarek.github.io/regex-learning-library/>
