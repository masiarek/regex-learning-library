//! `regex::escape`: the text that matches exactly the argument, as a pattern.
//! One line, so the quote keyword page can put it beside the other languages.
fn main() {
    let text = std::env::args().nth(1).expect("text to escape");
    println!("{}", regex::escape(&text));
}
