# Recursion and conditionals

The two constructs that take a regular expression furthest from being regular: one lets a pattern call itself, the other lets it branch on what it has already matched. Both exist in Perl and PCRE2 — so both exist in ABAP — and the support elsewhere is patchier, and more surprising, than the folklore says.

| Lesson | The question |
| --- | --- |
| [Matching nested structures](matching_nested_structures/README.md) | Balanced parentheses are not a regular language, so an engine either ships an explicit recursion construct or genuinely cannot express them. Two incompatible spellings — `(?R)` / `(?1)` / `(?&name)` in Perl and PCRE2, `\g<0>` / `\g<name>` in Ruby — and the dozen lines of host-language counting that beat both. |
| [Conditionals, and the `(?(DEFINE)…)` block](conditionals_and_define/README.md) | <code>(?(1)then&#124;else)</code> runs one branch or the other depending on whether group 1 participated. **Python's `re` has it**, which is the thing about conditionals most people get wrong. `(?(DEFINE)…)` is the closest a regular expression comes to declaring a function. |

**Two corrections this chapter makes to the library's own [engines page](../03_Engines/who_supports_what/README.md)**, both found by running rather than reading:

- **Ruby has recursion.** The probe there reports "no" because it asks for `(?R)`; Ruby's Onigmo spells it `\g<0>`. The two dialects have no overlap at all — Perl rejects every `\g<…>` form and Ruby rejects every `(?R)` form.
- **Compiling is not supporting.** JavaScript "accepts" `\g<0>` as an identity escape meaning the literal text `g<0>`, and Rust's `regex` "accepts" `(?R)` because `R` is its CRLF-mode flag. Both produce a pattern that matches something, silently, and neither is recursion.

**The judgement the chapter ends on.** Both constructs are real capabilities and both are, for most codebases, a maintenance liability: they are the patterns a reader is least likely to decode correctly, and the ones whose behaviour varies most between engines. Nested structure usually wants a parser; a conditional usually wants an `if` in the host language. Knowing when that is *not* true — a single pass over a large input, or a pattern that has to live in a config file where there is no host language — is what these two pages are for.
