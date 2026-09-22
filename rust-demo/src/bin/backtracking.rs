//! What a backtracker pays for the features an automaton refuses to have.

fn main() {
    let subject = "a".repeat(30) + "!";

    // No backreference, no lookaround: a finite automaton can answer this in
    // one pass over the subject, whatever the pattern's nesting looks like.
    let linear = regex::Regex::new(r"^(a+)+$").unwrap().is_match(&subject);
    println!("regex:       ^(a+)+$          -> {linear} (one pass, always)");

    // fancy-regex hands a pattern it has no special features for straight to
    // `regex`, so the same pattern is still linear here.
    let delegated = fancy_regex::Regex::new(r"^(a+)+$").unwrap().is_match(&subject);
    println!("fancy-regex: ^(a+)+$          -> {delegated:?} (delegated to regex)");

    // Add a backreference and delegation is off the table: the whole match has
    // to be backtracked, and this nesting makes that exponential. Rather than
    // run for years, fancy-regex counts its steps and gives up.
    match fancy_regex::Regex::new(r"^(a+)+\1$").unwrap().is_match(&subject) {
        Ok(m) => println!("fancy-regex: ^(a+)+\\1$        -> {m}"),
        Err(e) => println!("fancy-regex: ^(a+)+\\1$        -> {e}"),
    }
}
