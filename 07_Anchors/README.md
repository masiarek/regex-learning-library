# Anchors and flags

An anchor matches a position rather than a character, which makes it the cheapest thing in a pattern and the easiest to get wrong: nothing appears in the match to tell you the anchor meant something other than what you assumed. A flag has the same property one level up — it changes what `^`, `$` and `.` mean without changing a character of the pattern.

| Lesson | The question |
| --- | --- |
| [`$` is not the end of the string](dollar_and_the_end_of_the_string/README.md) | `$` matches at the end of the subject *or just before a final newline* in Perl, Python, Java and PCRE2 — and in Ruby `^` and `$` are line anchors always, with no flag involved. `^\d+$` is a question about a line, not about a value, and a validator built from it can be walked past. |
| [Flags, and where you can turn one on](flags_and_inline_modifiers/README.md) | Eight engines spell case-insensitivity `i` and then part company: `m` is *multiline* in seven of them and *dot-matches-newline* in Ruby. Inline `(?i)`, scoped `(?i:…)`, free-spacing `(?x)`, and which engines take which. |

**The rule the chapter ends on:** for validation, anchor with `\A` and `\z`, or use the language's own whole-string call — `re.fullmatch`, `String.matches`, an anchored `\A…\z` in Ruby. `^…$` is a line test that looks like a string test, and the difference is exactly one newline wide.

**A collision worth memorising before it costs you a day.** Python's `\Z` is Perl's `\z`. Perl's own `\Z` is something else again, and JavaScript has neither. That is three engines, one escape, and no error message anywhere.
