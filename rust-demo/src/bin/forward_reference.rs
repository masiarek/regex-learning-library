//! A forward reference: `\1` written before group 1 is defined.

fn main() {
    // Useful only inside a repetition: the first pass must fail the branch that
    // uses the group and take the branch that fills it.
    let pattern = r"^(?:\1x|(a))+$";

    match regex::Regex::new(pattern) {
        Ok(_) => println!("regex:       compiled"),
        Err(e) => println!("regex:       refused\n{e}"),
    }

    let re = fancy_regex::Regex::new(pattern).unwrap();
    for subject in ["aax", "ax", "aaxx"] {
        println!("fancy-regex: {subject:<5} {:?}", re.is_match(subject).unwrap());
    }
}
