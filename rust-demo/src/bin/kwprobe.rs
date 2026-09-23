//! The two Rust columns of tools/kwprobe/run.py: `regex` and `fancy-regex`,
//! one line per row, the two cells separated by a tab.
//!
//! `regex` is the automaton everybody uses; `fancy-regex` is the backtracking
//! layer over it that adds lookaround and backreferences. They are asked
//! separately because they disagree, and a page that said "Rust" would be
//! hiding which crate it meant.

use std::env;
use std::fs;

fn decode(s: &str) -> String {
    let chars: Vec<char> = s.chars().collect();
    let mut out = String::new();
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i];
        if c == '\\' && i + 1 < chars.len() {
            match chars[i + 1] {
                'n' => { out.push('\n'); i += 2; continue; }
                'r' => { out.push('\r'); i += 2; continue; }
                't' => { out.push('\t'); i += 2; continue; }
                '\\' => { out.push('\\'); i += 2; continue; }
                'u' if i + 2 < chars.len() && chars[i + 2] == '{' => {
                    let mut j = i + 3;
                    while j < chars.len() && chars[j] != '}' { j += 1; }
                    let hex: String = chars[i + 3..j].iter().collect();
                    if let Some(ch) = u32::from_str_radix(&hex, 16).ok().and_then(char::from_u32) {
                        out.push(ch);
                    }
                    i = j + 1;
                    continue;
                }
                _ => {}
            }
        }
        out.push(c);
        i += 1;
    }
    out
}

fn encode(s: &str) -> String {
    if s.is_empty() {
        return "\"\"".to_string();
    }
    let mut out = String::new();
    for c in s.chars() {
        match c {
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 0x20 || (c as u32) > 0x7e => out.push_str(&format!("\\u{{{:X}}}", c as u32)),
            c => out.push(c),
        }
    }
    out
}

struct Row {
    pattern: String,
    subject: Option<String>,
    replace: Option<String>,
    split: bool,
    skip: Vec<String>,
}

fn parse(line: &str) -> Row {
    let f: Vec<&str> = line.split(" :: ").map(str::trim).collect();
    let mut row = Row {
        pattern: f[1].to_string(),
        subject: f.get(2).map(|s| decode(s)),
        replace: None,
        split: false,
        skip: vec![],
    };
    for o in f.iter().skip(3) {
        if let Some(t) = o.strip_prefix("replace=") {
            row.replace = Some(decode(t));
        } else if *o == "split" {
            row.split = true;
        } else if let Some(list) = o.strip_prefix("skip=") {
            row.skip = list.split(',').map(String::from).collect();
        }
    }
    row
}

fn pieces(parts: Vec<&str>) -> String {
    let inner: Vec<String> = parts.iter().map(|p| if p.is_empty() { String::new() } else { encode(p) }).collect();
    format!("[{}]", inner.join(","))
}

fn with_regex(row: &Row) -> String {
    if row.skip.iter().any(|e| e == "rust") {
        return "n/a".into();
    }
    let re = match regex::Regex::new(&row.pattern) {
        Ok(re) => re,
        Err(_) => return "-".into(),
    };
    let Some(subject) = &row.subject else { return "ok".into() };
    if let Some(tmpl) = &row.replace {
        if re.find(subject).is_none() {
            return "no".into();
        }
        return encode(&re.replace(subject, tmpl.as_str()));
    }
    if row.split {
        return pieces(re.split(subject).collect());
    }
    match re.find(subject) {
        Some(m) => encode(m.as_str()),
        None => "no".into(),
    }
}

fn with_fancy(row: &Row) -> String {
    if row.skip.iter().any(|e| e == "fancy") {
        return "n/a".into();
    }
    let re = match fancy_regex::Regex::new(&row.pattern) {
        Ok(re) => re,
        Err(_) => return "-".into(),
    };
    let Some(subject) = &row.subject else { return "ok".into() };
    if let Some(tmpl) = &row.replace {
        return match re.find(subject) {
            Ok(Some(_)) => encode(&re.replace(subject, tmpl.as_str())),
            Ok(None) => "no".into(),
            Err(_) => "err".into(),
        };
    }
    if row.split {
        let mut parts = Vec::new();
        for p in re.split(subject) {
            match p {
                Ok(s) => parts.push(s),
                Err(_) => return "err".into(),
            }
        }
        return pieces(parts);
    }
    match re.find(subject) {
        Ok(Some(m)) => encode(m.as_str()),
        Ok(None) => "no".into(),
        Err(_) => "err".into(),
    }
}

fn main() {
    let path = env::args().nth(1).expect("rows file");
    let text = fs::read_to_string(&path).expect("read rows");
    for raw in text.lines() {
        let line = raw.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let row = parse(line);
        println!("{}\t{}", with_regex(&row), with_fancy(&row));
    }
}
