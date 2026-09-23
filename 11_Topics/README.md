# Topics

**One line:** One page per *job* — validating a field, pulling out a date, splitting a line, moving a pattern between two languages — each pulling together the keywords it needs and the chapters that measured them, with a table of its own where the job has an engine-dependent answer.

[Keywords](../10_Keywords/README.md) cuts the language by syntax; the [chapters](../00_Start_Here/README.md) cut it by question. This shelf cuts it by what you are trying to do. Where a keyword page answers "what does `\b` mean in Ruby", a topic page answers "how do I validate a name field, and what will go wrong".

Every table here is made the same way as on the Keywords shelf — one program, [`tools/kwprobe/run.py` ↗](https://github.com/masiarek/regex-learning-library/blob/master/tools/kwprobe/run.py), eight engines, the matched text or `no` or `-` per cell — so a topic page's claims are measured, not remembered. Three of the pages have no table because their subject is a *judgement* (performance, choosing an engine, testing); those say so and point at the pages where the measuring was done.

## Doing a job

| Topic | Level | In one line |
| --- | --- | --- |
| [Validating input](validating_input/README.md) | 201 | `^…$` is a line test that looks like a string test; `\A…\z`, `\d` versus `[0-9]`, and `(?i)` on the KELVIN SIGN |
| [Extracting fields](extracting_fields/README.md) | 201 | Name the groups, loop in the language: the last-iteration rule and the unset group, with the API per language |
| [Search and replace](search_and_replace/README.md) | 201 | First or all by default, the template language, the empty match, and when to use a function |
| [Splitting text](splitting_text/README.md) | 201 | Who returns a captured delimiter, and four answers to splitting on the empty pattern |
| [Escaping and literal text](escaping_and_literal_text/README.md) | 201 | The fourteen metacharacters, what `\q` does in seven engines, and six escape functions with three outputs |
| [Multiline text and logs](multiline_text_and_logs/README.md) | 201 | `(?m)`, `(?s)`, Ruby's letters, CRLF, `\R`, and the first and last line of a text |
| [Common patterns and their traps](common_patterns_and_their_traps/README.md) | 201 | Email, IPv4, date, decimal, quoted string, number — each with the input it wrongly accepts |
| [Readable patterns](readable_patterns/README.md) | 201 | `(?x)`, `#`, names and `(?(DEFINE)…)`, and how to build a pattern from parts where the engine has none of them |

## Staying out of trouble

| Topic | Level | In one line |
| --- | --- | --- |
| [Security](security/README.md) | 301 | The three regex mistakes that are vulnerabilities — `$`, `(?i)`, unescaped input — in one table, plus ReDoS |
| [Performance](performance/README.md) | 301 | Can it explode, how much per character, how often is it compiled — recorded as counts and cliffs, never timings |
| [Unicode text](unicode_text/README.md) | 301 | ASCII, code units, or code points? Ten rows that place every engine, and the five rules that survive all of them |
| [Testing patterns](testing_patterns/README.md) | 201 | The table every pattern deserves, the eight rows that find bugs, and how this library tests itself |

## Between engines

| Topic | Level | In one line |
| --- | --- | --- |
| [Portability between engines](portability_between_engines/README.md) | 301 | Refused, compiles-and-means-something-else, or same-construct-different-definition: twelve constructs, and the checklist |
| [Choosing an engine](choosing_an_engine/README.md) | 201 | Four families, one guarantee, and five questions — with where ABAP sits |
| [Command-line tools](command_line_tools/README.md) | 201 | BRE, ERE and PCRE behind three flags; leftmost-longest; no lazy quantifiers; and the shell gets the pattern first |
