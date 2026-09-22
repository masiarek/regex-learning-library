// Java has Unicode properties under its own spellings -- and a set of
// POSIX names that look identical and mean US-ASCII.
//
// A compact source file (Java 25): no class declaration, an instance main.
// Everything printed is a code point in hexadecimal, never a character: under
// LC_ALL=C a JVM's System.out is an ASCII encoder, and a page whose answer key
// depended on that would differ between a Mac and a CI runner.

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

static final int[] CAST = {
    0x0009, 0x0037, 0x0041, 0x00A0, 0x00E9,
    0x03B1, 0x0394, 0x0416, 0x0660, 0x2014, 0x4E2D,
};

static void who(String spelling, int flags) {
    Pattern re;
    try {
        re = Pattern.compile("^" + spelling + "$", flags);
    } catch (PatternSyntaxException e) {
        IO.println("  %-22srefused: %s".formatted(spelling, e.getDescription()));
        return;
    }
    StringBuilder hit = new StringBuilder();
    for (int cp : CAST) {
        if (re.matcher(new String(Character.toChars(cp))).matches()) {
            hit.append("%04X ".formatted(cp));
        }
    }
    String found = hit.toString().trim();
    IO.println("  %-22s%s".formatted(spelling, found.isEmpty() ? "(nothing)" : found));
}

static void who(String spelling) {
    who(spelling, 0);
}

static int count(String pattern, String subject) {
    Matcher m = Pattern.compile(pattern).matcher(subject);
    int n = 0;
    while (m.find()) {
        n++;
    }
    return n;
}

void main() {
    IO.println("general category: the one spelling everybody agrees on");
    for (String s : new String[] {"\\p{L}", "\\pL", "\\p{Lu}", "\\p{Nd}", "\\p{P}"}) {
        who(s);
    }

    IO.println("\nscript: Java wants Is, or script=, and refuses the bare name");
    for (String s : new String[] {"\\p{Greek}", "\\p{IsGreek}", "\\p{script=Greek}",
                                  "\\p{sc=Greek}", "\\p{InGreek}", "\\p{IsHan}"}) {
        who(s);
    }

    IO.println("\nbinary property: Is again");
    for (String s : new String[] {"\\p{Alphabetic}", "\\p{IsAlphabetic}",
                                  "\\p{White_Space}", "\\p{IsWhite_Space}", "\\p{gc=Lu}"}) {
        who(s);
    }

    IO.println("\nthe POSIX names -- same syntax, US-ASCII meaning");
    for (String s : new String[] {"\\p{Alpha}", "\\p{Digit}", "\\p{Upper}", "\\p{Punct}"}) {
        who(s);
    }

    IO.println("\nthe same POSIX names under UNICODE_CHARACTER_CLASS, or inline (?U)");
    for (String s : new String[] {"\\p{Alpha}", "\\p{Digit}", "\\p{Upper}", "\\p{Punct}"}) {
        who(s, Pattern.UNICODE_CHARACTER_CLASS);
    }

    String subject = new String(Character.toChars(0x0065)) + new String(Character.toChars(0x0301));
    IO.println("\ngrapheme clusters in U+0065 U+0301");
    IO.println("  %-22s%d".formatted("\\X", count("\\X", subject)));
    IO.println("  %-22s%d".formatted(".", count(".", subject)));
}
