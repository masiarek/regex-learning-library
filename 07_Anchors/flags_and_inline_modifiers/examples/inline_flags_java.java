// Java's flags: the int constants, the inline letters, and UNIX_LINES -- the
// only flag on this page whose job is to make an engine LESS aware of line
// breaks than it is by default.
//
// A Java 25 compact source file. No version, path or exception text is printed.

import java.util.regex.Matcher;
import java.util.regex.Pattern;

static final String THREE = "one\ntwo\nthree";
static final String CRLF = "abc\r\ndef";

static String esc(String s) {
    return "\"" + s.replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r") + "\"";
}

static void show(String label, String pattern, String subject, int flags) {
    String result;
    try {
        Matcher m = Pattern.compile(pattern, flags).matcher(subject);
        result = m.find() ? "match " + esc(m.group()) : "no match";
    } catch (Exception e) {
        result = "compile error";
    }
    IO.println(String.format("  %-30s %s", label, result));
}

static void show(String label, String pattern, String subject) {
    show(label, pattern, subject, 0);
}

void main() {
    IO.println("== the dot: what it excludes ==");
    IO.println("subject " + esc("one\ntwo"));
    show("one.two", "one.two", "one\ntwo");
    show("one.two  DOTALL", "one.two", "one\ntwo", Pattern.DOTALL);
    show("(?s)one.two", "(?s)one.two", "one\ntwo");
    IO.println("subject " + esc("one\rtwo"));
    show("one.two", "one.two", "one\rtwo");
    show("one.two  UNIX_LINES", "one.two", "one\rtwo", Pattern.UNIX_LINES);

    IO.println("== the letter m: line anchors ==");
    IO.println("subject " + esc(THREE));
    show("^two$", "^two$", THREE);
    show("^two$  MULTILINE", "^two$", THREE, Pattern.MULTILINE);
    show("(?m)^two$", "(?m)^two$", THREE);
    show("one.two  MULTILINE", "one.two", THREE, Pattern.MULTILINE);
    IO.println("subject " + esc(CRLF));
    show("^abc$  (?m)", "(?m)^abc$", CRLF);
    show("^abc$  (?m)(?d)", "(?m)(?d)^abc$", CRLF);

    IO.println("== free-spacing: COMMENTS / (?x) ==");
    String subject = "due 2026-09-22 ok";
    show("one line", "(\\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])", subject);
    show("(?x)", """
        (?x)
        (\\d{4})                    # year
        -
        (0[1-9] | 1[0-2])           # month, 01-12
        -
        (0[1-9] | [12]\\d | 3[01])  # day, 01-31
        """, subject);
    show("a b   (?x)  on " + esc("a b"), "(?x)a b", "a b");
    show("a b   (?x)  on " + esc("ab"), "(?x)a b", "ab");
    show("a\\ b  (?x)  on " + esc("a b"), "(?x)a\\ b", "a b");
    show("a#b   (?x)  on " + esc("a#b"), "(?x)a#b", "a#b");

    IO.println("== inline and scoped modifiers ==");
    show("abc            on ABC", "abc", "ABC");
    show("abc  CASE_INSENSITIVE", "abc", "ABC", Pattern.CASE_INSENSITIVE);
    show("(?i)abc        on ABC", "(?i)abc", "ABC");
    show("(?i:b)c        on Bc", "(?i:b)c", "Bc");
    show("(?i:b)c        on bC", "(?i:b)c", "bC");
    show("(?i)ab(?-i:cd) on ABcd", "(?i)ab(?-i:cd)", "ABcd");
    show("(?i)ab(?-i:cd) on ABCD", "(?i)ab(?-i:cd)", "ABCD");
    show("a(?i)bc        on aBC", "a(?i)bc", "aBC");
    show("a(?i)bc        on ABC", "a(?i)bc", "ABC");
    show("(a(?i)b)c      on aBc", "(a(?i)b)c", "aBc");
    show("(a(?i)b)c      on abC", "(a(?i)b)c", "abC");
}
