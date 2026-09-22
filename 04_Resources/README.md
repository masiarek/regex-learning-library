# Resources

## Documentation worth reading rather than searching

Each of these is the engine's own account of itself. When two pages in this library disagree with each other, one of these settles it.

| Engine | Where it documents itself |
| --- | --- |
| Perl | [perlre ↗](https://perldoc.perl.org/perlre) — the reference every other Perl-family page descends from |
| PCRE2 | [pcre2pattern ↗](https://www.pcre.org/current/doc/html/pcre2pattern.html) — the syntax ABAP's `PCRE` addition actually implements |
| ABAP | [Regular Expressions (ABAP Keyword Documentation) ↗](https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/abenregular_expressions.htm), and [String Processing in Release 7.55 ↗](https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/abennews-755-strings.htm) for what changed when `PCRE` arrived |
| Python | [`re` module ↗](https://docs.python.org/3/library/re.html), and the [regex HOWTO ↗](https://docs.python.org/3/howto/regex.html) |
| Rust | [`regex` syntax ↗](https://docs.rs/regex/latest/regex/#syntax) and [`fancy-regex` ↗](https://docs.rs/fancy-regex/) |
| Go | [`regexp/syntax` ↗](https://pkg.go.dev/regexp/syntax), and [RE2's own syntax page ↗](https://github.com/google/re2/wiki/Syntax) |
| JavaScript | [MDN regular expressions guide ↗](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions) |
| Java | [`java.util.regex.Pattern` ↗](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/regex/Pattern.html) — the class javadoc *is* the syntax reference |
| Ruby | [Regexp ↗](https://docs.ruby-lang.org/en/master/Regexp.html) |
| POSIX | [`regex(7)` ↗](https://man7.org/linux/man-pages/man7/regex.7.html) for BRE/ERE, which is what `grep` and `sed` implement |

Two more that are worth a bookmark each:

- [regex101 ↗](https://regex101.com/) — tests a pattern against subject text with a step-by-step explanation, and lets you pick the flavour (PCRE2, Python, Go, Java, JavaScript, Rust). Picking the right flavour is the whole value; a pattern debugged in the wrong one is debugged against the wrong engine.
- [Regular-Expressions.info ↗](https://www.regular-expressions.info/) — the most complete cross-engine reference on the web. Verify surprising claims against a run; a few of its cross-engine statements did not survive contact with the engines while this chapter was written.

## Books

Listed by what they are good for, not by rank.

**Jeffrey E. F. Friedl, *Mastering Regular Expressions* (3rd edition, O'Reilly).** The one book on this list that explains *why* an engine behaves as it does. Its chapters on the match mechanics — backtracking, the difference between a DFA and an NFA engine, and "the crafting of an efficient expression" — are the source most later writing draws from. Chapter 4 ("The Mechanics of Expression Processing") and chapter 6 ("Crafting an Efficient Expression") are the background to [what a backreference costs](../01_Backreferences/what_a_backreference_costs/README.md). The edition is old enough that the language-specific chapters have aged; the mechanics have not.

**Jan Goyvaerts and Steven Levithan, *Regular Expressions Cookbook* (2nd edition, O'Reilly).** Problem-shaped rather than concept-shaped, and unusually careful about flavour differences — most recipes are given per engine, which is exactly the axis this library is organised on. The best book to own if you write patterns for more than one language.

**Ben Forta, *Learning Regular Expressions* (Addison-Wesley).** Short, gentle, and the right recommendation for someone who needs to be productive this week. It will not tell you why your pattern is exponential.

**Michael Fitzgerald, *Introducing Regular Expressions* (O'Reilly).** A tutorial that works through one worked example at a time, with a good treatment of Unicode-aware classes.

**Tony Stubblebine, *Regular Expression Pocket Reference* (O'Reilly).** A flavour-by-flavour syntax table in book form. Largely superseded by having the documentation above open in a tab, but pleasant on paper.

## Sibling libraries

These pages deliberately stop where another library goes deeper.

| Library | What it covers that this one does not |
| --- | --- |
| [Python learning library ↗](https://masiarek.github.io/python-learning-library/) | The `re` module in the context of the rest of Python's text handling |
| [Rust learning library ↗](https://masiarek.github.io/rust-learning-library/) | Strings, ownership, and the crate ecosystem the regex crates live in |
| [ABAP learning library ↗](https://masiarek.github.io/abap-learning-library/) | ABAP itself — and it is where an ABAP example can be run and recorded properly |
| [Encodings learning library ↗](https://masiarek.github.io/encodings-learning-library/) | What a "character" is, which decides what `.` and `\w` match |
| [Perl learning library ↗](https://masiarek.github.io/perl-learning-library/) | Perl one-liners and text processing, where these patterns are most at home |
| [Java text learning library ↗](https://masiarek.github.io/java-text-learning-library/) | `java.util.regex` and the ASCII-by-default trap in `\w` |
| [Ruby text learning library ↗](https://masiarek.github.io/ruby-text-learning-library/) | Ruby's regex literals and its Perl heritage |
| [Linux learning library ↗](https://masiarek.github.io/linux-learning-library/) | `grep`, `sed` and the shell quoting that mangles patterns before the engine sees them |

## A note on what is *not* linked here

Local copies of these books sit on the machine this library was written on. Their filenames are not published, and neither are affiliate links — buy them from wherever you normally buy books.
