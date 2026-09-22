//! Does either Rust regex crate know "having matched this, never give it back"?
//!
//! `regex` is a finite automaton, so it has no backtracking to suppress; the
//! interesting question is what it does with the two spellings anyway. The
//! error text below is pinned by Cargo.lock, which is why `--locked` is not
//! decoration on the command that runs this.

/// Ask `regex`: does the pattern compile, and if it does, what does it match?
fn automaton(pattern: &str, subject: &str) {
    match regex::Regex::new(pattern) {
        Ok(re) => println!(
            "regex:       {pattern:<14} on {subject:<4} -> {}",
            re.is_match(subject)
        ),
        Err(e) => println!("regex:       {pattern:<14} refused --\n{e}"),
    }
}

/// Ask `fancy-regex`, the backtracking layer that has the features to suppress.
fn backtracker(pattern: &str, subject: &str) {
    match fancy_regex::Regex::new(pattern) {
        Ok(re) => println!(
            "fancy-regex: {pattern:<14} on {subject:<4} -> {:?}",
            re.is_match(subject)
        ),
        Err(_) => println!("fancy-regex: {pattern:<14} refused"),
    }
}

fn main() {
    // An atomic group is a thing `regex` has no syntax for at all.
    automaton(r"(?>a+)b", "aab");

    // A possessive quantifier, though, COMPILES here -- and does not mean what
    // it means in Perl. `a++` parses as a repetition of a repetition, so the
    // inner + is free to give a character back, and "aa" matches.
    automaton(r"a++a", "aa");
    automaton(r"a++b", "aab");

    // fancy-regex is the backtracker, and implements both for real.
    backtracker(r"(?>a+)b", "aab");
    backtracker(r"(?>a+)a", "aa");
    backtracker(r"a++b", "aab");
    backtracker(r"a++a", "aa");
    backtracker(r"^[\w.]++\.com$", "example.com");
}
