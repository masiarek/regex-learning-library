//! Flag letters in Rust's `regex`, which has two of them nobody else spells the
//! same way: `x` for free-spacing (Perl's letter, but Rust's flags are only ever
//! written inline) and `R`, a CRLF mode that makes `^`, `$` and `.` treat a
//! carriage return as part of the line break.
//!
//! `RegexBuilder` is the argument form; `(?i)` and friends are the inline form.
//! Both are shown, because the page's recommendation is to prefer the second.

use regex::{Regex, RegexBuilder};

const THREE: &str = "one\ntwo\nthree";
const CRLF: &str = "abc\r\ndef";

fn esc(s: &str) -> String {
    format!(
        "\"{}\"",
        s.replace('\\', "\\\\").replace('\n', "\\n").replace('\r', "\\r")
    )
}

fn show(label: &str, pattern: &str, subject: &str) {
    match Regex::new(pattern) {
        Err(_) => println!("  {label:<30} compile error"),
        Ok(re) => match re.find(subject) {
            Some(m) => println!("  {label:<30} match {}", esc(m.as_str())),
            None => println!("  {label:<30} no match"),
        },
    }
}

fn main() {
    println!("== the dot: what it excludes ==");
    println!("subject {}", esc("one\ntwo"));
    show("one.two", "one.two", "one\ntwo");
    show("(?s)one.two", "(?s)one.two", "one\ntwo");
    println!("subject {}", esc("one\rtwo"));
    show("one.two", "one.two", "one\rtwo");
    show("(?R)one.two", "(?R)one.two", "one\rtwo");

    println!("== the letter m: line anchors ==");
    println!("subject {}", esc(THREE));
    show("^two$", "^two$", THREE);
    show("(?m)^two$", "(?m)^two$", THREE);
    show("(?m)one.two", "(?m)one.two", THREE);
    println!("subject {}", esc(CRLF));
    show("(?m)^abc$", "(?m)^abc$", CRLF);
    show("(?mR)^abc$", "(?mR)^abc$", CRLF);

    println!("== free-spacing: (?x) ==");
    let subject = "due 2026-09-22 ok";
    show(
        "one line",
        r"(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])",
        subject,
    );
    show(
        "(?x)",
        r"(?x)
          (\d{4})                    # year
          -
          (0[1-9] | 1[0-2])          # month, 01-12
          -
          (0[1-9] | [12]\d | 3[01])  # day, 01-31
        ",
        subject,
    );
    show("(?x)a b   on \"a b\"", "(?x)a b", "a b");
    show("(?x)a b   on \"ab\"", "(?x)a b", "ab");
    show("(?x)a\\ b  on \"a b\"", r"(?x)a\ b", "a b");
    show("(?x)a#b   on \"a#b\"", "(?x)a#b", "a#b");

    println!("== the letter U, Go and Rust only ==");
    show("a+      on \"aaa\"", "a+", "aaa");
    show("(?U)a+  on \"aaa\"", "(?U)a+", "aaa");

    println!("== inline and scoped modifiers ==");
    show("abc            on ABC", "abc", "ABC");
    show("(?i)abc        on ABC", "(?i)abc", "ABC");
    show("(?i:b)c        on Bc", "(?i:b)c", "Bc");
    show("(?i:b)c        on bC", "(?i:b)c", "bC");
    show("(?i)ab(?-i:cd) on ABcd", "(?i)ab(?-i:cd)", "ABcd");
    show("(?i)ab(?-i:cd) on ABCD", "(?i)ab(?-i:cd)", "ABCD");
    show("a(?i)bc        on aBC", "a(?i)bc", "aBC");
    show("a(?i)bc        on ABC", "a(?i)bc", "ABC");
    show("(a(?i)b)c      on aBc", "(a(?i)b)c", "aBc");
    show("(a(?i)b)c      on abC", "(a(?i)b)c", "abC");

    println!("== the argument form, for comparison ==");
    let built = RegexBuilder::new("abc")
        .case_insensitive(true)
        .build()
        .unwrap();
    println!(
        "  {:<30} {}",
        "RegexBuilder case_insensitive",
        if built.is_match("ABC") { "match \"ABC\"" } else { "no match" }
    );
    println!("  {:<30} {}", "its pattern string", built.as_str());
}
