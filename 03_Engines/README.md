# Engines

The same pattern is not the same program. An engine decides which constructs exist, what an unset group means, whether a lookbehind may vary in width, and whether a hostile input can hold your server for an hour.

| Lesson | The question |
| --- | --- |
| [Who supports what](who_supports_what/README.md) | Eleven constructs × five engines, measured by compiling each pattern — plus the three engines that refuse the whole category, and where ABAP sits. |
| [When the engine has no lookaround](when_there_is_no_lookaround/README.md) | Rust's `regex` and Go's `regexp` have neither lookaround nor backreferences. What you write instead — and why one of the replacements is more correct than the lookahead it replaces. |

**The shortest version:** there are four lineages — Perl/PCRE (which includes ABAP), the Java/Ruby/JavaScript middle ground, Python's `re`, and the automata engines (Go, Rust's `regex`). Knowing which one you are talking to predicts more than any individual fact on this page.

**A caution about the table, worth reading before you trust a cell.** "Yes" on the probe means the engine compiled the pattern, and compiling is not supporting. Three of the differences this library has since measured are invisible to a compile test: Rust's `regex` accepts `a++` and reads it as `(a+)+`, it accepts `(?R)` because `R` is its CRLF flag, and JavaScript accepts `\g<0>` as the literal text `g<0>`. Each of those is a pattern that runs, matches something, and is not what the author wrote. Where a chapter needed a behaviour answer rather than a compile answer, it measured one — see [match semantics](../08_Match_Semantics/README.md), [recursion and conditionals](../09_Recursion/README.md), and [backtracking](../05_Backtracking/README.md).
