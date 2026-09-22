//! A conditional: `(?(1)then|else)`, branching on whether group 1 participated.
//!
//! Two crates, two answers. `regex` has no group references at all, so it has
//! nowhere to put a condition. `fancy-regex` backtracks, and -- unlike Java,
//! JavaScript and Go -- it does implement conditionals.

const SUBJECTS: [&str; 3] = ["<tag>", "tag", "<tag"];

/// Compile with fancy-regex and report yes/no per subject, or one word.
fn row(label: &str, pattern: &str) {
    match fancy_regex::Regex::new(pattern) {
        Err(_) => println!("{label:<30} refused"),
        Ok(re) => {
            let cells: String = SUBJECTS
                .iter()
                .map(|s| format!("{:<7}", if re.is_match(s).unwrap() { "yes" } else { "no" }))
                .collect();
            println!("{}", format!("{label:<30} {cells}").trim_end());
        }
    }
}

fn main() {
    let numbered = r"^(<)?\w+(?(1)>)$";

    // `regex` refuses, and says why. The message is pinned by Cargo.lock.
    match regex::Regex::new(numbered) {
        Ok(_) => println!("regex:       compiled"),
        Err(e) => println!("regex:       refused\n{e}"),
    }
    println!();

    println!(
        "{}",
        format!("fancy-regex{:<19} {:<7}{:<7}{:<7}", "", "<tag>", "tag", "<tag").trim_end()
    );
    row("numbered   (?(1)>)", numbered);
    row("named      (?(<open>)>)", r"^(?<open><)?\w+(?(<open>)>)$");
    row("named      (?(open)>)", r"^(?<open><)?\w+(?(open)>)$");
    // ...and a bare name no group in the pattern has.
    row("named      (?(zz)>)", r"^(?<open><)?\w+(?(zz)>)$");
    // The angle-bracket form of the same missing name IS checked.
    row("named      (?(<zz>)>)", r"^(?<open><)?\w+(?(<zz>)>)$");
    row("lookaround (?(?=<)...|...)", r"^(?(?=<)<\w+>|\w+)$");
    row("DEFINE     (?(DEFINE)...)", r"(?(DEFINE)(?<octet>\d))^\g<octet>$");
    println!();

    // A condition naming a group that is not in the pattern.
    let missing = r"^(a)(?(2)x|y)$";
    println!(
        "(a)(?(2)x|y) with no group 2: {}",
        match fancy_regex::Regex::new(missing) {
            Ok(_) => "compiled",
            Err(_) => "refused",
        }
    );
}
