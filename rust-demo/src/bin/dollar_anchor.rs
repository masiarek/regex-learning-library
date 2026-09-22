//! What `$` anchors to in Rust's two regex crates.
//!
//! `regex` is RE2-shaped, so `$` is the end of the haystack by default and
//! `(?m)` turns it into a line anchor. `fancy-regex` is a backtracking layer
//! on top, so it is the one that might have inherited Perl's newline clause.
//! Both are asked the same question here rather than assumed.

const SUBJECTS: [&str; 3] = ["1", "1\n", "1\nrm -rf /"];

fn row(label: &str, cells: [&str; 3]) {
    println!("{label:<30}{:<8}{:<8}{}", cells[0], cells[1], cells[2]);
}

fn verdicts(pattern: &str) -> [&'static str; 3] {
    match regex::Regex::new(pattern) {
        Err(_) => ["error", "error", "error"],
        Ok(re) => {
            let mut cells = ["no"; 3];
            for (i, s) in SUBJECTS.iter().enumerate() {
                if re.is_match(s) {
                    cells[i] = "match";
                }
            }
            cells
        }
    }
}

fn fancy(pattern: &str) -> [&'static str; 3] {
    match fancy_regex::Regex::new(pattern) {
        Err(_) => ["error", "error", "error"],
        Ok(re) => {
            let mut cells = ["no"; 3];
            for (i, s) in SUBJECTS.iter().enumerate() {
                if re.is_match(s).unwrap() {
                    cells[i] = "match";
                }
            }
            cells
        }
    }
}

fn main() {
    println!("rust regex");
    row("pattern", [r#""1""#, r#""1\n""#, r#""1\nrm -rf /""#]);
    row(r"^\d+$", verdicts(r"^\d+$"));
    row(r"\A\d+\z", verdicts(r"\A\d+\z"));
    row(r"\A\d+\Z", verdicts(r"\A\d+\Z"));
    row(r"(?m)^\d+$", verdicts(r"(?m)^\d+$"));

    println!();
    println!("rust fancy-regex");
    row("pattern", [r#""1""#, r#""1\n""#, r#""1\nrm -rf /""#]);
    row(r"^\d+$", fancy(r"^\d+$"));
    row(r"\A\d+\z", fancy(r"\A\d+\z"));
    row(r"\A\d+\Z", fancy(r"\A\d+\Z"));
    row(r"(?m)^\d+$", fancy(r"(?m)^\d+$"));

    // The flag letters: `regex` spells the line-anchor flag m and the dot flag
    // s, inline, the same way Go does.
    println!();
    row("flag (regex)", ["none", "(?m)", "(?s)"]);
    row(
        r#"^\d+$ on "1\nrm -rf /""#,
        [one(r"^\d+$"), one(r"(?m)^\d+$"), one(r"(?s)^\d+$")],
    );
    row(
        r#"a.b on "a\nb""#,
        [dot(r"a.b"), dot(r"(?m)a.b"), dot(r"(?s)a.b")],
    );

    // `\Z` is an escape `regex` does not know -- and, per the table above, one
    // `fancy-regex` does, with Perl's meaning. The message is pinned by
    // Cargo.lock and `--locked`, so it can be printed as it is.
    println!();
    match regex::Regex::new(r"\A\d+\Z") {
        Ok(_) => println!(r"regex: \A\d+\Z compiles"),
        Err(e) => println!("regex: {e}"),
    }
}

fn one(pattern: &str) -> &'static str {
    hit(pattern, "1\nrm -rf /")
}

fn dot(pattern: &str) -> &'static str {
    hit(pattern, "a\nb")
}

fn hit(pattern: &str, subject: &str) -> &'static str {
    if regex::Regex::new(pattern).unwrap().is_match(subject) {
        "match"
    } else {
        "no"
    }
}
