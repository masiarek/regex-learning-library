# Backtracking

Every engine in the Perl family answers a hard question by *searching*: try something, and on failure go back and try something else. That search is what makes lookaround and backreferences possible, and it is also the reason a pattern five characters long can fail to answer at all. This chapter is about the search — how to make it explode, how to tell, and the one construct that cuts it dead.

| Lesson | The question |
| --- | --- |
| [Catastrophic backtracking, with no backreference anywhere](catastrophic_backtracking/README.md) | `(a+)+`, `(a\|a)*`, `^(\w+\s?)*$` and almost every hand-written email validator. Which engines never answer, which answer until the shape changes slightly, and why the subject that triggers it is one that *fails* to match. |
| [Atomic groups and possessive quantifiers](atomic_groups_and_possessive_quantifiers/README.md) | `(?>a+)` and `a++`: one instruction in two spellings. What they fix, and the more important half — that they change **what a pattern matches**, not only how long it takes to fail. |

**The two sentences the chapter turns on.** The first: a nested quantifier over something that can match the same text more than one way gives a backtracker exponentially many things to try, and hostile input picks the worst one. The second: "does not explode" is not the same claim as "is bounded" — Perl 5.42 and Java 25 answer every backreference-free shape measured here, and their work still grows quadratically, so a megabyte finds the cliff a hundred characters did not.

**Where the rest of the story is.** [What a backreference costs](../01_Backreferences/what_a_backreference_costs/README.md) is the theory — why a backreference takes a pattern outside what a finite automaton can represent, and why Go's RE2 and Rust's `regex` refuse the feature in exchange for a guarantee. Read it first if you want to know *why*; read this chapter if you have a request timing out.
