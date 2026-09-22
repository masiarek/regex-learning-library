//! Leftmost-first, in an engine that does not backtrack.
//!
//! `regex` is a finite automaton with a linear-time guarantee, which is the
//! same family as RE2 and Go's `regexp`. It is still leftmost-FIRST: the order
//! of the alternatives decides the answer. `fancy-regex` backtracks and agrees
//! with it. Neither exposes a leftmost-longest switch on `Regex`.

use fancy_regex::Regex as Fancy;
use regex::Regex;

fn crate_regex(pattern: &str, subject: &str) -> String {
    match Regex::new(pattern).unwrap().find(subject) {
        Some(m) => m.as_str().to_string(),
        None => "-".to_string(),
    }
}

fn crate_fancy(pattern: &str, subject: &str) -> String {
    match Fancy::new(pattern).unwrap().find(subject).unwrap() {
        Some(m) => m.as_str().to_string(),
        None => "-".to_string(),
    }
}

fn main() {
    let cases = [
        (r"a|ab", "ab"),
        (r"ab|a", "ab"),
        (r"[0-9]+|[0-9]+\.[0-9]+", "v 3.14 w"),
        (r"[0-9]+\.[0-9]+|[0-9]+", "v 3.14 w"),
    ];

    println!(
        "{:<22} {:<9} {:<9} {}",
        "pattern", "subject", "regex", "fancy-regex"
    );
    for (pattern, subject) in cases {
        println!(
            "{:<22} {:<9} {:<9} {}",
            pattern,
            subject,
            crate_regex(pattern, subject),
            crate_fancy(pattern, subject)
        );
    }

    // The same subexpression question the C and the five-engine examples ask.
    println!();
    println!("(a|ab)(c|bcd)(d*) on abcd");
    let pattern = r"(a|ab)(c|bcd)(d*)";
    let caps = Regex::new(pattern).unwrap().captures("abcd").unwrap();
    println!(
        "regex       whole={} g1={} g2={} g3={}",
        &caps[0], &caps[1], &caps[2], &caps[3]
    );
    let caps = Fancy::new(pattern).unwrap().captures("abcd").unwrap().unwrap();
    println!(
        "fancy-regex whole={} g1={} g2={} g3={}",
        &caps[0], &caps[1], &caps[2], &caps[3]
    );
}
