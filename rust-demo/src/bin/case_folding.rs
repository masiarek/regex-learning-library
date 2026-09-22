//! What `(?i)` folds in the `regex` crate, and what `str` methods fold instead.
//!
//! `regex` implements Unicode *simple* case folding; `str::to_lowercase` and
//! `str::to_uppercase` implement *full* case mapping. The two do not agree, and
//! this program shows where.
//!
//! Characters are built from code points and named by code point, so the output
//! is ASCII on any machine.

fn cp(n: u32) -> String {
    char::from_u32(n).unwrap().to_string()
}

fn yn(hit: bool) -> &'static str {
    if hit { "yes" } else { "no" }
}

fn main() {
    let kelvin = cp(0x212A);
    let long_s = cp(0x017F);
    let sharp_s = cp(0x00DF);
    let cap_sharp_s = cp(0x1E9E);
    let dotless_i = cp(0x0131);
    let dotted_i = cp(0x0130);
    let dot_above = cp(0x0307);

    let probes: Vec<(&str, String, &str, String)> = vec![
        ("k", "k".into(), "U+004B LATIN CAPITAL LETTER K", "K".into()),
        ("k", "k".into(), "U+212A KELVIN SIGN", kelvin.clone()),
        ("s", "s".into(), "U+017F LATIN SMALL LETTER LONG S", long_s.clone()),
        ("U+00DF", sharp_s.clone(), "U+1E9E LATIN CAPITAL LETTER SHARP S", cap_sharp_s.clone()),
        ("U+1E9E", cap_sharp_s.clone(), "U+00DF LATIN SMALL LETTER SHARP S", sharp_s.clone()),
        ("ss", "ss".into(), "U+00DF LATIN SMALL LETTER SHARP S", sharp_s.clone()),
        ("[k]", "[k]".into(), "U+212A KELVIN SIGN", kelvin.clone()),
        ("[a-z]", "[a-z]".into(), "U+212A KELVIN SIGN", kelvin.clone()),
        ("i", "i".into(), "U+0131 LATIN SMALL LETTER DOTLESS I", dotless_i.clone()),
        ("i", "i".into(), "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", dotted_i.clone()),
        (
            "i U+0307",
            format!("i{dot_above}"),
            "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE",
            dotted_i.clone(),
        ),
    ];

    let hit = |pattern: &str, subject: &str| -> String {
        let re = regex::Regex::new(&format!("(?i)^(?:{pattern})$")).unwrap();
        yn(re.is_match(subject)).to_string()
    };
    let hit_fancy = |pattern: &str, subject: &str| -> String {
        let re = fancy_regex::Regex::new(&format!("(?i)^(?:{pattern})$")).unwrap();
        yn(re.is_match(subject).unwrap()).to_string()
    };

    println!("does (?i) match?          rust crates, anchored");
    println!("{:<9} {:<46} {:<6}{}", "pattern", "subject", "regex", "fancy");
    for (pat_name, pattern, sub_name, subject) in &probes {
        println!(
            "{:<9} {:<46} {:<6}{}",
            pat_name,
            sub_name,
            hit(pattern, subject),
            hit_fancy(pattern, subject)
        );
    }

    println!();
    println!("does (?i) fold the BACKREFERENCE comparison too?");
    match regex::Regex::new(r"(?i)(a)\1") {
        Ok(_) => println!("regex        compiled"),
        Err(e) => println!(
            "regex        (?i)(a)\\1                  {}",
            e.to_string().lines().last().unwrap_or("").trim()
        ),
    }
    let fancy = fancy_regex::Regex::new(r"(?i)(a)\1").unwrap();
    println!(
        "fancy-regex  (?i)(a)\\1  vs 'a' + U+0041   {}",
        yn(fancy.is_match("aA").unwrap())
    );
    let fancy_k = fancy_regex::Regex::new(r"(?i)(k)\1").unwrap();
    println!(
        "fancy-regex  (?i)(k)\\1  vs 'k' + U+212A   {}",
        yn(fancy_k.is_match(&format!("k{kelvin}")).unwrap())
    );

    println!();
    println!("one program, two answers about the same pair");
    let row = |label: &str, std_answer: bool, re_answer: String| {
        println!("  {:<38}{:<8} regex (?i): {}", label, std_answer, re_answer);
    };
    row("to_uppercase(U+00DF) is 'SS'", sharp_s.to_uppercase() == "SS", hit("SS", &sharp_s));
    row(
        "eq_ignore_ascii_case(U+00DF, 'ss')",
        sharp_s.eq_ignore_ascii_case("ss"),
        hit("ss", &sharp_s),
    );
    row("to_lowercase(U+212A) is 'k'", kelvin.to_lowercase() == "k", hit("k", &kelvin));
    row("to_uppercase(U+017F) is 'S'", long_s.to_uppercase() == "S", hit("s", &long_s));
    row(
        "to_lowercase(U+1E9E) is U+00DF",
        cap_sharp_s.to_lowercase() == sharp_s,
        hit(&sharp_s, &cap_sharp_s),
    );
}
