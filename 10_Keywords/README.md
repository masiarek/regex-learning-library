# Keywords

**One line:** One page per construct — every anchor, class, quantifier, group and control verb — each with a table produced by handing the same rows to eight engines, so the page says what `\b` or `(?>…)` or `$1` *does*, per engine, rather than what a cheat sheet says it means.

The [chapters](../00_Start_Here/README.md) are organised by question. This shelf is organised by *syntax*: it is where to go when you are looking at a pattern and want to know what one piece of it means in the engine you are holding. [Topics](../11_Topics/README.md) is the third cut — one page per job, pulling keywords and chapters together.

## How a keyword page is made

Every table on this shelf comes from one program, [`tools/kwprobe/run.py` ↗](https://github.com/masiarek/regex-learning-library/blob/master/tools/kwprobe/run.py), which takes rows of *label, pattern, subject* and asks eight engines the same question: does it compile, does it match, and what exactly did it match. The engines are Python (3.12, the CI runner's version), Perl, JavaScript (Node), Ruby, Java, Go, and Rust's `regex` and `fancy-regex` crates. A cell is the matched text, `no` for compiled-but-no-match, `-` for refused, and `n/a` where the driver was told not to ask because the answer depends on a runtime version that differs between the author's machine and CI.

Two consequences worth knowing before reading a table. **A `-` is good news** — the engine told you it does not have the feature. **A `no` next to a `-` is the cell to look at**: it often means the engine compiled the construct as something else (JavaScript's identity escapes, Rust's `(?R)` flag, Ruby's `\pL`) and the page will say so. And PCRE2 — which is ABAP's engine — has no column, because nothing on the CI runner speaks it; where it matters a page carries a dated `pcre2grep` run instead.

## Anchors and boundaries

| Keyword | Page | In one line |
| --- | --- | --- |
| `^` | [Start of subject, or of a line, or "not"](caret/README.md) | A line anchor always in Ruby, only under `m` elsewhere; negation or a literal inside a class |
| `$` | [The end, plus one newline you did not ask for](dollar/README.md) | Steps over a final newline in four engines, any newline in Ruby, none in JavaScript, Go, Rust |
| `\A`, `\z`, `\Z` | [The anchors that mean what `^` and `$` are assumed to mean](start_and_end_of_subject/README.md) | Python's `\Z` is Perl's `\z`; JavaScript has none of them and matches the letters |
| `\b`, `\B` | [A boundary is wherever `\w` says it is](word_boundary/README.md) | Ruby's `\b` and `\w` disagree with each other; Rust's `regex` has GNU's `\<` `\>` |
| `\G` | [Where the last match ended](continue_anchor/README.md) | The tokenizer anchor, with a lexer in Perl and Java |

## Characters and classes

| Keyword | Page | In one line |
| --- | --- | --- |
| `.` | [Any character, except the ones it is not](dot/README.md) | Refuses `\n` everywhere and `\r` in two engines; the flag is `s`, or `m` in Ruby |
| `[…]` | [A set of characters, and the two whose position matters](character_class/README.md) | `]` first, `-` last, and `&&` set arithmetic in Ruby, Java and Rust only |
| `\d`, `\w`, `\s` | [And `\h`, `\v`, `\R`, `\N`](shorthand_classes/README.md) | ASCII in four engines, Unicode in four; `\v` is a vertical tab in five |
| `[[:alpha:]]` | [POSIX bracket classes](posix_classes/README.md) | Four engines have them, four read the same text as a class of six characters |
| `\p{…}` | [A character by what it is](unicode_property/README.md) | Three spellings for one script, no spelling all engines take; Python has none |
| `\X` | [One character as a person counts it](grapheme_cluster/README.md) | Perl, Ruby and Java keep a family emoji whole; `.` splits it everywhere |

## Quantifiers

| Keyword | Page | In one line |
| --- | --- | --- |
| `*`, `+`, `?` | [Zero or more, one or more, at most one](star_plus_question/README.md) | `x*` always succeeds; `x**` is legal in Ruby and Rust |
| `{n,m}` | [Counted repetition](braces/README.md) | `{,2}` is a quantifier in four engines and the literal text in two |
| `*?`, `+?` | [As little as possible](lazy_quantifier/README.md) | Same answer in all eight; POSIX reads `a+?` as `(a+)?` |
| `*+`, `++` | [Greedy, and never gives it back](possessive_quantifier/README.md) | `a++a` cannot match — except in Rust, where `++` is `(a+)+` |

## Groups and references

| Keyword | Page | In one line |
| --- | --- | --- |
| `(…)` | [A group that remembers](capturing_group/README.md) | Numbered by opening bracket, keeps the last iteration, unset on the other branch |
| `(?:…)` | [A group that does not count](non_capturing_group/README.md) | And its scoped-flag form `(?i:…)` |
| `(?<n>…)` | [Three ways to name a group, four to refer to it](named_group/README.md) | No definition spelling and no reference spelling that all eight accept |
| `\1` | [Match the text group 1 matched](backreference/README.md) | Unset groups, forward references and `\10` — five answers to one escape |
| `$1`, `\1`, `${n}` | [The replacement string is a second language](replacement_references/README.md) | Fourteen rows, no universal spelling, and two engines that insert a NUL |
| `(?\|…)` | [Alternatives that share group numbers](branch_reset/README.md) | Perl and PCRE2 only |
| `\|` | [This or that, in this order](alternation/README.md) | First alternative that works wins, in all eight — order is meaning |

## Lookaround and control

| Keyword | Page | In one line |
| --- | --- | --- |
| `(?=…)`, `(?!…)` | [Assert what follows](lookahead/README.md) | Negative lookahead after a quantifier matches one character too early |
| `(?<=…)`, `(?<!…)` | [Assert what precedes, and how wide](lookbehind/README.md) | Four width rules across six engines |
| `(?>…)` | [Once matched, never given back](atomic_group/README.md) | Changes the match, not only the speed; `(?=(…))\1` rebuilds it in JavaScript |
| `(?(1)…\|…)` | [A branch that depends on the match so far](conditional/README.md) | Python has it; `fancy-regex` compiles the bare-name form and inverts it |
| `(?R)`, `\g<0>` | [Call the pattern again](recursion_and_subroutine_calls/README.md) | Two dialects with no overlap, and two engines that accept one while meaning something else |
| `\K` | [Keep everything before this out of the match](keep_out/README.md) | The unlimited-width lookbehind, in Perl, PCRE2 and Ruby |
| `(*SKIP)(*F)` | [Steering the backtracker by hand](backtracking_verbs/README.md) | Perl and PCRE2 only; the idiom for "commas not inside quotes" |

## Flags, comments and options

| Keyword | Page | In one line |
| --- | --- | --- |
| `(?i)`, `(?m)`, `(?s)`, `(?x)` | [A flag that travels with the pattern](inline_flags/README.md) | Ruby's `m` and Java's `U` and `u` mean something else |
| `(?#…)`, `#` | [Comments inside a pattern](comment/README.md) | Adding `(?x)` to an old pattern silently truncates it at the first `#` |
| `\Q…\E` | [Quote a run of metacharacters](quote/README.md) | Lives in the engine in Java and Go, in the *string* in Perl; six escape functions, three answers |
| `(*UCP)`, `(*UTF)`, `(*CRLF)` | [PCRE2's start-of-pattern options](start_of_pattern_options/README.md) | Refused by all eight engines here; measured with pcre2grep, because they are ABAP's |
