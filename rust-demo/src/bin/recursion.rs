//! Recursion, asked of both Rust crates.
//!
//! Neither has it. The interesting part is *how* they say no: `regex` accepts
//! `(?R)` -- as a flag group, not as recursion -- and quietly matches a
//! different language than the one you wrote.

fn main() {
    let patterns = [
        (r"(?R)", r"^\((?:[^()]|(?R))*\)$"),
        (r"(?1)", r"^(\((?:[^()]|(?1))*\))$"),
        (r"\g<0>", r"^\((?:[^()]|\g<0>)*\)$"),
    ];

    for (label, pattern) in patterns {
        println!("{label}");
        match regex::Regex::new(pattern) {
            Ok(_) => println!("  regex:       COMPILED"),
            Err(e) => println!("  regex:       refused -- {}", one_line(&e.to_string())),
        }
        match fancy_regex::Regex::new(pattern) {
            Ok(_) => println!("  fancy-regex: COMPILED"),
            Err(e) => println!("  fancy-regex: refused -- {}", one_line(&e.to_string())),
        }
    }

    // The one that compiled. `R` is `regex`'s flag for CRLF line terminators,
    // so `(?R)` sets a flag and consumes nothing: the alternation branch that
    // was meant to recurse is empty, and the pattern collapses to "one level of
    // parentheses". Nothing reports a problem at any point.
    let fake = regex::Regex::new(r"^\((?:[^()]|(?R))*\)$").unwrap();
    println!("\nwhat regex's (?R) pattern actually matches");
    for subject in ["(a(b)c)", "((a)(b))", "(ab)", "()", "a"] {
        println!("  {subject:<10} {}", fake.is_match(subject));
    }
}

fn one_line(s: &str) -> String {
    s.split_whitespace().collect::<Vec<_>>().join(" ")
}
