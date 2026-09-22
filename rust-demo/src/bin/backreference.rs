//! Does Rust's regex have backreferences? Two crates, two answers.

fn main() {
    // `\1` means "the same text group 1 already matched". The `regex` crate
    // does not accept it -- and the interesting part is the reason it gives.
    match regex::Regex::new(r"\b(\w+) \1\b") {
        Ok(_) => println!("regex:       compiled (this would be news)"),
        Err(e) => println!("regex:       refused\n{e}"),
    }

    // fancy-regex backtracks, so it can look at what group 1 captured.
    let re = fancy_regex::Regex::new(r"\b(\w+) \1\b").unwrap();
    let text = "the the doubled word is is easy to miss";
    for m in re.find_iter(text).flatten() {
        println!("fancy-regex: found {:?} at byte {}", m.as_str(), m.start());
    }
}
