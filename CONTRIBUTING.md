# Adding a lesson

The conventions are few, and most exist to keep one promise: **a page never claims something a program has not actually printed.**

## The shape of a lesson

```
NN_Chapter/
  topic_name/
    README.md                     the lesson
    examples/
      topic_name_py.py            a program that demonstrates it
      topic_name_py.out           its recorded output — the answer key
      topic_name_pl.pl            the same question, another engine
      z_topic_name.prog.abap      ABAP: source only, no key (see below)
```

A folder's overview page is named exactly `README.md`: GitHub renders it in the folder's tree view, and MkDocs makes it that section's landing page. The descriptive title goes in the page's `# H1`, not in the filename.

**Stems are unique across the whole repo**, because a Markdown block names a bare stem with no path and no extension. The convention is a language suffix: `doubled_word_py`, `doubled_word_pl`, `doubled_word_rs_sh`.

## The one rule

Mark where output belongs and let the tool fill it:

```markdown
<!-- output:doubled_word_py -->
<!-- /output -->
```

Then run `python3 tools/run_examples.py`. It runs the program, compares it with the recorded `.out`, and rewrites the block. Inside the markers is generated; outside is yours. `<!-- source:stem -->` pastes the program itself the same way — use it instead of hand-copying code onto a page, because a hand-pasted copy is one that can quietly stop matching the program CI runs.

CI runs `--check`, which writes nothing and fails if code, key and page have drifted apart.

## The languages

| Extension | How it runs |
| --- | --- |
| `.py` | `python3 -I`, standard library only |
| `.pl` | perl 5.36+ |
| `.js` | node |
| `.rb` | ruby 3.2+ (macOS's `/usr/bin/ruby` is 2.6 — the runner looks for a newer one) |
| `.go` | `go build`, Go 1.25+, standard library only |
| `.java` | `java <file>.java`, Java 25+ |
| `.c` | `cc -std=c17`, for POSIX `<regex.h>` |
| `.sh` | bash — for `grep`, `sed`, `cargo`, and anything about an exit status |
| `.abap` | **never run here.** See below. |

**Rust has no regular expressions in its standard library**, so a Rust example is a question about a crate. The crates live in one Cargo workspace at [`rust-demo/`](rust-demo/Cargo.toml) with a bin per lesson, and a `.sh` example runs it:

```bash
cargo run --locked --quiet --manifest-path ../../../rust-demo/Cargo.toml --bin backreference
```

`--locked` is not decoration. These examples print **error messages**, and a silent minor bump that rewords one is exactly the drift this library exists to catch.

## The ABAP column

Nothing in this repository can run ABAP, and neither can a GitHub runner. So:

- An `.abap` file is **source only**. It has no `.out` key, `run_examples.py` skips it, and a page shows it with a `source:` block.
- **Never write an output block for an ABAP example**, and never hand-type what you think it would print. If you have run it on a real system, record the transcript with a provenance line saying which system and release — the way the [ABAP learning library ↗](https://masiarek.github.io/abap-learning-library/) does — and label it as such.
- What *can* be shown is the engine underneath. ABAP's `PCRE` addition is the PCRE2 library, and PCRE2 is on any machine with `pcre2grep`. Those go on a page as a dated **Real run** fence naming the version and the machine, not as a generated block.
- Name ABAP files the abapGit way — `z_name.prog.abap`, `zcl_name.clas.abap`. abaplint types an object from that infix and analyses **nothing** without it, and its way of saying so is the words `0 file(s) analyzed`, which look exactly like success.

## Writing the prose

- **One idea per page.** Two H1-sized ideas are two pages.
- **Lead with the shortest true statement** — a `**One line:**` summary the reader can carry away — then earn it.
- **`**Level:**`** tags the depth: `101`, `201`, `301` or `reference`, then ` · ` and the audience.
- **Say which trap you are describing.** The valuable half of most lessons is the mistake, not the mechanism.
- **Say which engine and which version.** "Regular expressions support lookbehind" is not a true sentence. `(?<=a{1,3})b` compiles in Perl, Java and JavaScript, and is an error in Python and Ruby — that is a true sentence.
- **Put every engine's answer next to the others.** This library exists for the comparison; a page about one language belongs in that language's own library.
- **Don't hard-wrap paragraphs.** One paragraph, one line.

## Linking

- **Link a folder by naming its README**: `[label](some_folder/README.md)`, never `[label](some_folder/)`. The bare form works on GitHub and on the built site but not in a plain Markdown viewer, and MkDocs ships it unrewritten so it 404s.
- **Every external link ends its label with ` ↗`** and no internal link does, so a reader can tell without hovering which links leave the library. `tools/check_link_style.py --fix` maintains this; CI checks it.

## Reading order in the sidebar

Set it in `NAV_ORDER` in [`mkdocs_hooks.py` ↗](https://github.com/masiarek/regex-learning-library/blob/master/mkdocs_hooks.py) — never by renaming files. A filename is a permanent URL; inserting one lesson would otherwise move every page after it. Numeric prefixes on *chapter* folders are fine (the hook strips them from the label).

## Before you commit

```bash
python3 tools/check_all.py --staged
```

That runs every gate CI runs, against the tree your next commit would make: the examples, the link style, the nav chain, and `mkdocs build --strict`.
