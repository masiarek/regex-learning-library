# Backreferences

A regular expression, in the strict sense, has no memory. It walks the subject and decides; it cannot say "the same thing I just saw". A **backreference** is the feature that breaks that rule, and this chapter is about what it buys and what it costs.

Four lessons, in reading order:

| Lesson | The question |
| --- | --- |
| [What a backreference is](what_a_backreference_is/README.md) | `\1` matches the *text* group 1 captured — spelled in Python, Perl, JavaScript, Go, Rust, grep and ABAP. |
| [Forward references](forward_references/README.md) | The same `\1`, written *before* its group. Legal in Perl, PCRE2, ABAP, Java, Ruby and JavaScript; a compile error in Python. And the four names people confuse with it. |
| [Backreferences in the replacement](backreferences_in_the_replacement/README.md) | The `\1` on the right-hand side of a substitution, which is not a backreference and does not behave like one. |
| [What a backreference costs](what_a_backreference_costs/README.md) | Why Go's RE2 and Rust's `regex` refuse the feature, measured rather than asserted. |

**If you are new to the whole area:** the first lesson is self-contained. If you have used `\1` for years and want the part that surprises people, start with forward references.

**The one sentence the chapter keeps returning to:** a backreference matches *text*, never a pattern. Everything else — why it makes matching exponential, why RE2 has none, why an unset group is a philosophical question — follows from that.
