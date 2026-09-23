# Performance

**One line:** Regex performance is three separate questions — can this pattern explode, how much does it do per character, and how often is it compiled — and this library records answers to the first two as step counts and cliffs rather than timings, because a timing is not a fact about the pattern.

**Level:** 301 · a pattern is slow, or you are choosing one for a hot path

## Why there are no timings here

A key in this library must be byte-identical on the author's Mac and on the Ubuntu CI runner. A millisecond is not. So the measured pages record what *can* be recorded: whether an engine answered within a fixed cap, how many characters a Java `CharSequence` was asked for, how many match steps PCRE2 needed before its limit tripped. Those are properties of the pattern and the engine, and they reproduce.

## Question 1 — can it explode?

The only performance question that matters until it is answered. A backtracking engine with a nested quantifier over overlapping alternatives — `(a+)+`, `(\w+\s?)*`, most hand-written email validators — can take exponential time on a subject that *fails*, and the subject is chosen by whoever sends the input.

- **The shape**, and which engines never answer, answer until the input grows, or cannot be made to explode: [Catastrophic backtracking](../../05_Backtracking/catastrophic_backtracking/README.md).
- **The construct that cuts the search dead**, and what it does to the match: [Atomic groups and possessive quantifiers](../../05_Backtracking/atomic_groups_and_possessive_quantifiers/README.md).
- **The theory** — why a backreference forces backtracking at all: [What a backreference costs](../../01_Backreferences/what_a_backreference_costs/README.md).
- **The engine choice** that makes the question go away: Go's `regexp` and Rust's `regex` are linear in the subject by construction. [Choosing an engine](../choosing_an_engine/README.md).

## Question 2 — how much per character?

Once a pattern cannot explode, it can still do more work than it needs to, and the differences are constant factors that add up on a large input:

| Do | Instead of | Because |
| --- | --- | --- |
| `[^"]*` | `.*?` | the class stops on its own; the lazy quantifier retries the tail at every step — [measured in read counts](../../08_Match_Semantics/greedy_and_lazy/README.md) |
| anchor: `^…` or `\A…` | an unanchored pattern that must start at 0 | without the anchor the engine tries every offset |
| a literal prefix first | `\w+@…` | engines search for literal prefixes with fast string search before running the automaton |
| `(?:…)` | `(…)` | a capture costs bookkeeping on every backtrack; only capture what code reads |
| longest alternative first | `\d+\|\d+\.\d+` | in a leftmost-first engine the order decides both the answer and how many attempts are made — [alternation](../../10_Keywords/alternation/README.md) |
| a possessive or atomic group | a greedy one that can never usefully give back | but only where nothing after can overlap — [possessive](../../10_Keywords/possessive_quantifier/README.md) |
| a specific class | `.` | `.` has to be told at every position that this is not a newline |

None of these is worth doing until question 1 is answered, and none of them is worth doing at all on a pattern that runs once.

## Question 3 — how often is it compiled?

Compilation is the expensive step in every engine: parsing, building the automaton or the backtracking program, the Unicode tables. A pattern compiled inside a loop is compiled once per iteration.

| Language | Compile once | The trap |
| --- | --- | --- |
| Python | `re.compile` at module level | `re.match(p, s)` in a loop is fine — `re` caches the last 512 patterns — until the loop uses more than 512 |
| Perl | `qr//` once; a constant `//` is compiled with the program | `/$var/` recompiles when `$var` changes; add `/o` only if it never does |
| JavaScript | a literal `/…/` at module level | `new RegExp(s)` in a loop compiles every time |
| Ruby | a literal at module level, or a constant | `Regexp.new` in a loop |
| Java | `static final Pattern` | `String.matches(regex)` compiles every call |
| Go | `regexp.MustCompile` at package level | `regexp.MatchString` compiles every call |
| Rust | `LazyLock<Regex>` or `OnceLock` | `Regex::new` in a loop — and Clippy warns |

## Keywords on this page

[Possessive quantifier](../../10_Keywords/possessive_quantifier/README.md) · [Atomic group](../../10_Keywords/atomic_group/README.md) · [Lazy quantifier](../../10_Keywords/lazy_quantifier/README.md) · [Alternation](../../10_Keywords/alternation/README.md) · [Non-capturing group](../../10_Keywords/non_capturing_group/README.md) · [Backtracking verbs](../../10_Keywords/backtracking_verbs/README.md) · [`(*LIMIT_MATCH)`](../../10_Keywords/start_of_pattern_options/README.md).

## See also

- [Backtracking](../../05_Backtracking/README.md) — the chapter.
- [Russ Cox, *Regular Expression Matching Can Be Simple And Fast* ↗](https://swtch.com/~rsc/regexp/regexp1.html) — why the automata engines are built the way they are.
