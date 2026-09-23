# Testing patterns

**One line:** A regex is code that is easy to test and almost never tested — a table of inputs and expected answers, including the ones that must *not* match and the ones that must not *hang* — and this page is how this library tests its own claims, turned into a recipe.

**Level:** 201 · you have a pattern and a feeling it works

## What a pattern test looks like

Four columns: the input, whether it should match, what it should capture, and — for anything untrusted input reaches — that it answers at all.

```text
input                 match?   groups                note
2026-09-22            yes      2026, 09, 22
2026-9-22             no                             single-digit month
2026-09-22\n          no                             trailing newline — the $ trap
2026-13-45            yes      2026, 13, 45          shape only; the date library rejects it
"" (empty)            no
aaaaaaaaaaaaaaaaaaa!  answers                        the catastrophic probe
```

The rows that find bugs are the *negative* ones and the *edge* ones. A pattern that matches its three happy-path examples has been demonstrated, not tested.

## The rows every table should have

| Row | Catches |
| --- | --- |
| The empty string | `x*` and `a?` patterns that always succeed — [`*`, `+`, `?`](../../10_Keywords/star_plus_question/README.md) |
| The input with a trailing newline | `$` stepping over it — [`$`](../../10_Keywords/dollar/README.md) |
| The input with a second line | Ruby's line anchors; `(?m)` left on — [`^`](../../10_Keywords/caret/README.md) |
| A non-ASCII letter, digit, and the KELVIN SIGN | `\w`, `\d`, `(?i)` being ASCII or not — [Unicode text](../unicode_text/README.md) |
| A subject that *almost* matches, one character short | the catastrophic shape — [catastrophic backtracking](../../05_Backtracking/catastrophic_backtracking/README.md) |
| The longest input you will ever see, failing | the same, at the size that matters |
| A metacharacter in any user-supplied piece | missing escaping — [escaping](../escaping_and_literal_text/README.md) |
| The same table in the second engine, if there is one | everything on the [portability](../portability_between_engines/README.md) page |

## How this library tests

Every generated block on every page is the output of a program under `examples/`, re-run on every push and compared byte-for-byte with a recorded `.out` file, on a second machine (the Ubuntu CI runner) with different versions of Python, Ruby and Node. A page cannot claim something a program did not print. That is a stronger test than most production patterns get, and the recipe transfers:

1. **Record the expected output, do not assert it.** `tools/run_examples.py --update` writes what the program printed; a human reads the diff. Asserting `assert m.group(1) == "2026"` in a test is the same idea with more typing.
2. **Run in the engine that ships.** The probe behind the [Keywords](../../10_Keywords/README.md) pages runs Python 3.12 because CI does, not the newer one on the author's machine. Test where it runs.
3. **Keep the negative cases in the same table as the positives.** They are the ones that go stale first.
4. **Cap the runtime.** The catastrophic-backtracking examples run each subject in a child process with a time limit and record "answered" or "no answer" — the only portable way to test that a pattern *terminates*. A test suite without a timeout on its regex tests has not tested ReDoS.

## The tools that help

- A **table-driven test** in the language's ordinary test framework: `pytest.mark.parametrize`, `Test::More`'s `is`, Jest's `test.each`, RSpec, JUnit's `@ParameterizedTest`, Go's table tests, Rust's `#[test]` over a `const` array. Nothing regex-specific is needed.
- **regex101 ↗** (<https://regex101.com/>) for the step-by-step debugger — in the *right flavour*, which is the whole value.
- **`tools/kwprobe/run.py`** in this repository, if the question is "what does engine X do with construct Y": one row, eight answers, ten seconds.

## Keywords on this page

[`^`](../../10_Keywords/caret/README.md) · [`$`](../../10_Keywords/dollar/README.md) · [`\A`, `\z`](../../10_Keywords/start_and_end_of_subject/README.md) · [`*`, `+`, `?`](../../10_Keywords/star_plus_question/README.md) · [Shorthand classes](../../10_Keywords/shorthand_classes/README.md).

## See also

- [Validating input](../validating_input/README.md) · [Security](../security/README.md) — the two topics whose bugs a table finds.
- [CONTRIBUTING](../../CONTRIBUTING.md) — the one rule, and how the blocks are filled.
