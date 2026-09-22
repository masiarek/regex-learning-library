// Java copied Perl's `$`, newline clause and all -- and then widened it.
// `matcher.find()` is a search, so `^\d+$` is a search for a position, not a
// statement about the whole input. `String.matches` is the whole input.

import java.util.regex.Pattern;

static final String[] SUBJECTS = {"1", "1\n", "1\nrm -rf /"};

static void row(String label, String a, String b, String c) {
    System.out.printf("%-30s%-8s%-8s%s%n", label, a, b, c);
}

static void find(String label, String pattern, int flags) {
    String[] cells = new String[3];
    for (int i = 0; i < SUBJECTS.length; i++) {
        cells[i] = Pattern.compile(pattern, flags).matcher(SUBJECTS[i]).find() ? "match" : "no";
    }
    row(label, cells[0], cells[1], cells[2]);
}

void main() {
    System.out.println("java");
    row("pattern", "\"1\"", "\"1\\n\"", "\"1\\nrm -rf /\"");
    find("find(), ^\\d+$", "^\\d+$", 0);
    find("find(), \\A\\d+\\z", "\\A\\d+\\z", 0);
    find("find(), \\A\\d+\\Z", "\\A\\d+\\Z", 0);
    find("find(), MULTILINE ^\\d+$", "^\\d+$", Pattern.MULTILINE);
    row("String.matches(\"\\\\d+\")",
        SUBJECTS[0].matches("\\d+") ? "match" : "no",
        SUBJECTS[1].matches("\\d+") ? "match" : "no",
        SUBJECTS[2].matches("\\d+") ? "match" : "no");

    // Java's idea of a line terminator is larger than anyone else's: CR, LF,
    // CRLF, NEL (U+0085), LINE SEPARATOR (U+2028) and PARAGRAPH SEPARATOR
    // (U+2029) all end a line, so all of them split a subject for MULTILINE
    // ^ and $. UNIX_LINES narrows that back to LF alone.
    System.out.println();
    System.out.println("MULTILINE ^\\d+$ against one payload per terminator");
    String[] shown = {"\"1\\nrm -rf /\"", "\"1\\r\\nrm -rf /\"",
                      "\"1\\u0085rm -rf /\"", "\"1\\u2028rm -rf /\""};
    String[] raw = {"1\nrm -rf /", "1\r\nrm -rf /", "1rm -rf /", "1 rm -rf /"};
    for (int i = 0; i < raw.length; i++) {
        System.out.printf("%-30s%-8s%s%n", shown[i],
            Pattern.compile("^\\d+$", Pattern.MULTILINE).matcher(raw[i]).find() ? "match" : "no",
            Pattern.compile("^\\d+$", Pattern.MULTILINE | Pattern.UNIX_LINES)
                   .matcher(raw[i]).find() ? "match (UNIX_LINES)" : "no (UNIX_LINES)");
    }

    // And the plain `$`, with no MULTILINE at all, still steps over a final
    // CRLF -- the newline clause is about a line terminator, not about LF.
    System.out.println();
    System.out.printf("%-30s%s%n", "find(), ^\\d+$ on \"1\\r\\n\"",
        Pattern.compile("^\\d+$").matcher("1\r\n").find() ? "match" : "no");
    System.out.printf("%-30s%s%n", "find(), \\A\\d+\\z on \"1\\r\\n\"",
        Pattern.compile("\\A\\d+\\z").matcher("1\r\n").find() ? "match" : "no");
}
