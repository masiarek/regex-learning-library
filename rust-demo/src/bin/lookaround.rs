//! Lookaround: a test that consumes nothing.

fn main() {
    match regex::Regex::new(r"foo(?=bar)") {
        Ok(_) => println!("regex:       refused nothing? (unexpected)"),
        Err(e) => println!("regex:       refused\n{e}"),
    }

    // fancy-regex has lookahead, and lookbehind of a KNOWN width.
    let re = fancy_regex::Regex::new(r"(?<=EUR )\d+").unwrap();
    println!("fancy-regex: fixed-width lookbehind -> {:?}",
             re.find("EUR 250").unwrap().map(|m| m.as_str()));

    // A lookbehind whose width can vary is a compile error, not a slow match.
    match fancy_regex::Regex::new(r"(?<=EUR\s{1,4})\d+") {
        Ok(_) => println!("fancy-regex: variable-width lookbehind compiled"),
        Err(e) => println!("fancy-regex: variable-width lookbehind -> {e}"),
    }
}
