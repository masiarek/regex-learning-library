# Engines

The same pattern is not the same program. An engine decides which constructs exist, what an unset group means, whether a lookbehind may vary in width, and whether a hostile input can hold your server for an hour.

| Lesson | The question |
| --- | --- |
| [Who supports what](who_supports_what/README.md) | Eleven constructs × five engines, measured by compiling each pattern — plus the three engines that refuse the whole category, and where ABAP sits. |

**The shortest version:** there are four lineages — Perl/PCRE (which includes ABAP), the Java/Ruby/JavaScript middle ground, Python's `re`, and the automata engines (Go, Rust's `regex`). Knowing which one you are talking to predicts more than any individual fact on this page.
