//! What `\w`, `\d`, `\s` and `\b` match in Rust's `regex` -- Unicode by default,
//! and `(?-u)` is the way back to ASCII.
//!
//! Every character is built from its code point and every matched token is
//! escaped back to ASCII, so the recorded answer key cannot depend on a locale.

const PROBES: [(&str, u32); 7] = [
    ("U+0041 LATIN CAPITAL LETTER A", 0x0041),
    ("U+00E9 LATIN SMALL LETTER E WITH ACUTE", 0x00E9),
    ("U+0301 COMBINING ACUTE ACCENT", 0x0301),
    ("U+0660 ARABIC-INDIC DIGIT ZERO", 0x0660),
    ("U+FF11 FULLWIDTH DIGIT ONE", 0xFF11),
    ("U+00A0 NO-BREAK SPACE", 0x00A0),
    ("U+3000 IDEOGRAPHIC SPACE", 0x3000),
];

fn ch(cp: u32) -> String {
    char::from_u32(cp).expect("valid scalar value").to_string()
}

fn esc(s: &str) -> String {
    s.chars()
        .map(|c| {
            let n = c as u32;
            if (0x20..=0x7E).contains(&n) {
                c.to_string()
            } else {
                format!("\\u{n:04X}")
            }
        })
        .collect()
}

/// "does this class match this one character?", reporting a refusal instead of
/// panicking on it.
fn hit(class: &str, s: &str) -> &'static str {
    match regex::Regex::new(&format!(r"\A(?:{class})\z")) {
        Err(_) => "ERR",
        Ok(re) if re.is_match(s) => "yes",
        Ok(_) => "no",
    }
}

fn pad(s: &str, n: usize) -> String {
    format!("{s:<n$}")
}

fn table(title: &str, w: &str, d: &str, sp: &str) {
    println!("{title}");
    let width = [w, d, sp].iter().map(|s| s.len()).max().unwrap() + 2;
    println!("{}{}{}{}", pad("", 40), pad(w, width), pad(d, width), sp);
    for (label, cp) in PROBES {
        let c = ch(cp);
        println!(
            "{}{}{}{}",
            pad(label, 40),
            pad(hit(w, &c), width),
            pad(hit(d, &c), width),
            hit(sp, &c)
        );
    }
    println!();
}

fn main() {
    // "naive" with U+00EF LATIN SMALL LETTER I WITH DIAERESIS in the middle.
    let subject = format!("na{}ve reader", ch(0x00EF));
    // "012" written with U+0660..U+0662 ARABIC-INDIC DIGIT ZERO..TWO.
    let arabic_indic: String = [0x0660, 0x0661, 0x0662].iter().map(|&c| ch(c)).collect();

    table("regex crate, default -- Unicode:", r"\w", r"\d", r"\s");
    table("the same pattern inside (?-u:...):", r"(?-u:\w)", r"(?-u:\d)", r"(?-u:\s)");

    println!(r"\b\w+\b over 'na' U+00EF 've reader' -- how many words?");
    for pat in [r"\b\w+\b", r"(?-u:\b\w+\b)"] {
        let re = regex::Regex::new(pat).unwrap();
        let found: Vec<String> = re.find_iter(&subject).map(|m| esc(m.as_str())).collect();
        println!("  {} -> {}   {}", pad(pat, 16), found.len(), found.join(" "));
    }
    let fancy = fancy_regex::Regex::new(r"\b\w+\b").unwrap();
    let found: Vec<String> = fancy
        .find_iter(&subject)
        .flatten()
        .map(|m| esc(m.as_str()))
        .collect();
    println!(
        "  {} -> {}   {}   (fancy-regex)",
        pad(r"\b\w+\b", 16),
        found.len(),
        found.join(" ")
    );
    println!();

    println!(r"\d and the number that follows it (subject is U+0660 U+0661 U+0662):");
    println!(r"  \d+            -> {}", hit(r"\d+", &arabic_indic));
    println!(r"  (?-u:\d+)      -> {}", hit(r"(?-u:\d+)", &arabic_indic));
    match arabic_indic.parse::<u32>() {
        Ok(n) => println!("  parse::<u32>() -> {n}"),
        Err(e) => println!("  parse::<u32>() -> {e}"),
    }
    println!();

    println!("what the crate refuses, and why it is not arbitrary:");
    for pat in [r"(?-u:\w)", r"(?-u:\W)", r"(?-u:.)"] {
        match regex::Regex::new(pat) {
            Ok(_) => println!("  {}  compiles", pad(pat, 12)),
            Err(_) => println!("  {}  refused -- it could match a byte that is not UTF-8", pad(pat, 12)),
        }
    }
}
