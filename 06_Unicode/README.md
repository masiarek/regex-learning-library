# Unicode

`\w`, `\d`, `\b` and `(?i)` were all defined when a character was a byte, and every engine has since had to decide what they mean for the rest of the world. They decided differently. This is the chapter where the same pattern, over the same text, produces different answers in engines nobody would call buggy.

| Lesson | The question |
| --- | --- |
| [What `\w` and `\b` match once the subject is not ASCII](what_w_and_b_match/README.md) | ASCII-only by default in JavaScript, Java, Ruby, Go and PCRE2 — so in ABAP; Unicode-aware by default in Python `str`, Perl and Rust's `regex`. The same twelve characters hold one word in Ruby, two in Python and three in JavaScript. |
| [Naming a Unicode property: `\p{...}`](unicode_properties/README.md) | Asking whether a character is a letter instead of listing the letters you hope it is. The engines agree about what Greek is and disagree about how to spell it — and two of them accept a misspelling without a word. |
| [`(?i)` is a folding table, not an instruction to ignore case](case_insensitive_matching/README.md) | U+212A KELVIN SIGN folding to `k`, U+00DF matching `ss` in Perl and Ruby and nowhere else, and the engine whose own string comparison disagrees with its own regex. |

**The thing worth carrying away from all three:** these are not corner cases dressed up. A validation pattern written against English names and tested against English names will reject, truncate or silently accept the wrong thing the first time someone else's name arrives — and the failure is a match result, not an exception.

**Where a character comes from.** What `.` even counts as one is a question this library deliberately stops short of; the [Encodings learning library ↗](https://masiarek.github.io/encodings-learning-library/) is where it belongs. The relevant half here is that an engine's answer often depends on whether the subject arrived as bytes or as decoded text — in the same language, with the same pattern.
