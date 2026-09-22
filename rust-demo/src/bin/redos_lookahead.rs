//! Catastrophic backtracking with no backreference anywhere in the pattern.
//!
//! The sibling lesson asks what a *backreference* costs. This one asks the other
//! question: what do the two Rust crates do with an ordinary nested quantifier --
//! the shape a person writes by accident -- on a subject built to fail?

const EMAIL: &str = r"^([a-zA-Z0-9_\.\-])+@(([a-zA-Z0-9\-])+\.)+([a-zA-Z]{2,4})+$";

fn row(crate_name: &str, pattern: &str, subject: &str, answer: String) {
    println!("  {crate_name:<12} {pattern:<17} {subject:<22} {answer}");
}

fn fancy(pattern: &str, subject: &str, described: &str, shown: &str) {
    let answer = match fancy_regex::Regex::new(pattern).unwrap().is_match(subject) {
        Ok(true) => "match".to_string(),
        Ok(false) => "no match".to_string(),
        Err(e) => e.to_string(),
    };
    row("fancy-regex", shown, described, answer);
}

fn main() {
    // 120 a's and then one character that cannot match. Python and node never
    // answer this one. An automaton has no choices to regret, so the nesting
    // costs `regex` nothing -- and neither does a subject a thousand times longer.
    let hostile = "a".repeat(120) + "!";
    let huge = "a".repeat(100_000) + "!";

    println!("patterns with no backreference, rust:");

    let nested = regex::Regex::new(r"^(a+)+$").unwrap();
    for (subject, described) in [(&hostile, "120 a's then '!'"), (&huge, "100000 a's then '!'")] {
        let hit = if nested.is_match(subject) { "match" } else { "no match" };
        row("regex", "^(a+)+$", described, hit.to_string());
    }
    let email = regex::Regex::new(EMAIL).unwrap();
    let hit = if email.is_match(&huge) { "match" } else { "no match" };
    row("regex", "the email regex", "100000 a's then '!'", hit.to_string());

    // fancy-regex hands any part of a pattern it has no special feature for
    // straight to `regex`. A lookahead in FRONT of the loop leaves the loop
    // itself delegated, so this is still one linear pass.
    fancy(r"^(?=a)(a+)+$", &hostile, "120 a's then '!'", "^(?=a)(a+)+$");

    // Move the same lookahead INSIDE the loop and there is nothing left to
    // delegate: fancy-regex must run its own backtracking VM over the nesting.
    // Still no backreference anywhere. It counts its steps and refuses.
    fancy(r"^((?=a)a+)+$", &hostile, "120 a's then '!'", "^((?=a)a+)+$");

    // The fix is in the pattern, not the crate: make the inner repetition atomic
    // so there is nothing left to back off into.
    fancy(r"^((?=a)(?>a+))+$", &hostile, "120 a's then '!'", "^((?=a)(?>a+))+$");
}
