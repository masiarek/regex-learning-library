//! `\p{...}`: the crate with the most complete property support of any engine
//! this library measures.
//!
//! `regex` takes the bare script name, the `Script=` form, the `sc=` form and
//! Perl's `Is` prefix; it knows the binary properties; and it is the only
//! engine here with set operations inside a character class. What it does not
//! have is `\X`.
//!
//! Every character is written and reported as a code point, so the recorded
//! answer key is the same on macOS and on Ubuntu.

const CAST: [u32; 11] = [
    0x0009, 0x0037, 0x0041, 0x00A0, 0x00E9, 0x03B1, 0x0394, 0x0416, 0x0660, 0x2014, 0x4E2D,
];

fn who(spelling: &str) {
    match regex::Regex::new(&format!("^(?:{spelling})$")) {
        Err(_) => println!("  {spelling:<30}refused"),
        Ok(re) => {
            let hit: Vec<String> = CAST
                .iter()
                .filter(|cp| re.is_match(&char::from_u32(**cp).unwrap().to_string()))
                .map(|cp| format!("{cp:04X}"))
                .collect();
            let found = hit.join(" ");
            println!("  {spelling:<30}{}", if found.is_empty() { "(nothing)".into() } else { found });
        }
    }
}

fn main() {
    println!("general category");
    for s in [r"\p{L}", r"\pL", r"\p{Lu}", r"\p{Nd}", r"\p{Zs}", r"\p{P}", r"\P{L}"] {
        who(s);
    }

    println!("\nscript -- every spelling this page has met");
    for s in [r"\p{Greek}", r"\p{Script=Greek}", r"\p{sc=Greek}", r"\p{IsGreek}",
              r"\p{Script_Extensions=Greek}", r"\p{Han}"] {
        who(s);
    }

    println!("\nbinary property");
    for s in [r"\p{Alphabetic}", r"\p{Uppercase}", r"\p{White_Space}", r"\p{Alpha}", r"\p{Any}"] {
        who(s);
    }

    println!("\nset operations inside a class -- regex alone among these engines");
    for s in [r"[\p{L}\p{Nd}]", r"[\p{Greek}&&\p{Lu}]", r"[\p{L}--\p{Greek}]",
              r"[\p{Greek}~~\p{Lu}]"] {
        who(s);
    }

    println!("\nno grapheme cluster escape in either crate");
    match regex::Regex::new(r"\X") {
        Ok(_) => println!("  regex        compiles"),
        Err(e) => println!("  regex        {}", e.to_string().lines().last().unwrap_or("")),
    }
    match fancy_regex::Regex::new(r"\X") {
        Ok(_) => println!("  fancy-regex  compiles"),
        Err(e) => println!("  fancy-regex  {e}"),
    }
}
