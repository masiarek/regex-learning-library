//! Greedy and lazy in Rust's two regex crates.
//!
//! `regex` is a finite automaton with no backtracking at all, so there is no
//! "give one character back" to describe. It still honours `*?`, because the
//! difference is which match the engine PREFERS, and a preference can be
//! compiled into the automaton. `fancy-regex` backtracks, and agrees.

use fancy_regex::Regex as Fancy;
use regex::Regex;

fn main() {
    let subject = "<b>bold</b>";
    println!("subject: {subject}");
    for pattern in ["<.+>", "<.+?>", "<[^>]+>"] {
        let first = Regex::new(pattern).unwrap().find(subject).unwrap();
        let fancy = Fancy::new(pattern).unwrap().find(subject).unwrap().unwrap();
        println!(
            "  {pattern:<9} regex {:<12} fancy-regex {}",
            format!("{:?}", first.as_str()),
            format!("{:?}", fancy.as_str())
        );
    }

    println!("subject: aaa");
    for pattern in ["a+", "a+?", "a*?", "a{1,3}?"] {
        let first = Regex::new(pattern).unwrap().find("aaa").unwrap();
        let fancy = Fancy::new(pattern).unwrap().find("aaa").unwrap().unwrap();
        println!(
            "  {pattern:<9} regex {:<12} fancy-regex {}",
            format!("{:?}", first.as_str()),
            format!("{:?}", fancy.as_str())
        );
    }
}
