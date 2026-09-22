//! What you write when the engine has no lookaround.
//!
//! Three jobs lookahead is normally used for, done with `regex` alone.

use regex::{Regex, RegexSet};

fn main() {
    // 1. "All of these rules at once" -- the password idiom. With lookahead it
    //    is (?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}. Without it, the rules are a
    //    SET, which is closer to what the code actually means.
    let rules = RegexSet::new([r"[a-z]", r"[A-Z]", r"[0-9]"]).unwrap();
    for pw in ["Sunshine1", "sunshine1", "Sun1"] {
        let hits = rules.matches(pw);
        let ok = hits.iter().count() == rules.len() && pw.chars().count() >= 8;
        println!("{pw:<10} rules matched {:?}  accepted {ok}", hits.into_iter().collect::<Vec<_>>());
    }

    // RegexSet also answers WHICH rule failed, which one big lookahead pattern
    // cannot do at all -- the error message is free.
    let names = ["a lowercase letter", "an uppercase letter", "a digit"];
    let missing: Vec<_> = (0..rules.len())
        .filter(|i| !rules.matches("sunshine1").matched(*i))
        .map(|i| names[i])
        .collect();
    println!("sunshine1 is missing: {missing:?}");

    // 2. "X not followed by Y". The lookahead version is \d+(?! EUR) -- which
    //    is a trap anyway (it matches "25" of "250"). Match the optional tail
    //    and look at what you captured.
    let amount = Regex::new(r"(\d+)( EUR)?").unwrap();
    for caps in amount.captures_iter("250 EUR and 90 USD") {
        if caps.get(2).is_none() {
            println!("not in EUR: {}", &caps[1]);
        }
    }

    // 3. "X preceded by Y" -- lookbehind. Capture the prefix and ignore it:
    //    the match offsets tell you where the part you wanted starts.
    let priced = Regex::new(r"EUR (\d+)").unwrap();
    for caps in priced.captures_iter("EUR 250 USD 90") {
        let m = caps.get(1).unwrap();
        println!("after EUR: {:?} at byte {}", m.as_str(), m.start());
    }
}
