# Match semantics

A pattern that compiles everywhere still has to be told *which* match to return, and there is more than one defensible answer. Two engines can hold the same pattern and the same subject, agree that it matches, and hand back different text. Nothing in the syntax says which rule you are talking to.

| Lesson | The question |
| --- | --- |
| [Two definitions of "the match": leftmost-first and leftmost-longest](leftmost_first_vs_leftmost_longest/README.md) | <code>a&#124;ab</code> against `ab` gives `a` in Perl, Python, Java, Ruby, JavaScript, Rust and Go, and `ab` in POSIX `grep`, `sed`, `awk` and C's `<regex.h>`. Both are right. One of them makes the order of your alternatives load-bearing. |
| [Greedy and lazy — and the engine that reads `*?` as something else](greedy_and_lazy/README.md) | Greedy takes as much as it can and gives it back; lazy takes as little as it can and takes more. They differ in which match is found, not in how fast — and in a POSIX engine `a+?` is not a lazy quantifier at all, it is `(a+)?`, which compiles and means something else. |

**The shape both lessons share**, and the reason they sit in one chapter: a pattern that is *accepted* by the second engine is far more dangerous than one that is rejected. A compile error is a bug report. A different answer is a defect that ships.

**Where this bites in practice.** Moving a pattern between a language and the command line — Python to `awk`, Perl to `sed`, a service to a `grep` in a shell script — crosses the boundary in both lessons at once. See [who supports what](../03_Engines/who_supports_what/README.md) for which family each engine belongs to.
