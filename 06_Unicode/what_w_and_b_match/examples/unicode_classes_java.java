// What \w, \d, \s and \b match in java.util.regex -- ASCII until you say otherwise.
//
// A Java 25 compact source file: no class declaration, run with `java <file>.java`.
// Every character is built with Character.toChars, never written literally, and
// nothing non-ASCII is ever printed -- under LC_ALL=C a JVM's System.out encoding
// is US-ASCII, and a raw accented character would come out differently on two
// machines. Name the code point instead.

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

static final String[][] PROBES = {
    { "U+0041 LATIN CAPITAL LETTER A", "0041" },
    { "U+00E9 LATIN SMALL LETTER E WITH ACUTE", "00E9" },
    { "U+0301 COMBINING ACUTE ACCENT", "0301" },
    { "U+0660 ARABIC-INDIC DIGIT ZERO", "0660" },
    { "U+FF11 FULLWIDTH DIGIT ONE", "FF11" },
    { "U+00A0 NO-BREAK SPACE", "00A0" },
    { "U+3000 IDEOGRAPHIC SPACE", "3000" },
};

static String ch(String hex) {
    return new String(Character.toChars(Integer.parseInt(hex, 16)));
}

static String esc(String s) {
    StringBuilder b = new StringBuilder();
    for (int cp : s.codePoints().toArray()) {
        if (cp >= 0x20 && cp <= 0x7E) {
            b.append((char) cp);
        } else {
            b.append(String.format("\\u%04X", cp));
        }
    }
    return b.toString();
}

static String hit(String src, String s) {
    return Pattern.matches("(?:" + src + ")", s) ? "yes" : "no";
}

static String pad(String s, int n) {
    return s.length() >= n ? s : s + " ".repeat(n - s.length());
}

static void table(String title, String w, String d, String sp) {
    System.out.println(title);
    int width = Math.max(Math.max(w.length(), d.length()), sp.length()) + 2;
    System.out.println(pad("", 40) + pad(w, width) + pad(d, width) + sp);
    for (String[] probe : PROBES) {
        String c = ch(probe[1]);
        System.out.println(pad(probe[0], 40) + pad(hit(w, c), width)
            + pad(hit(d, c), width) + hit(sp, c));
    }
    System.out.println();
}

void main() {
    // "naive" with U+00EF LATIN SMALL LETTER I WITH DIAERESIS in the middle.
    String subject = "na" + ch("00EF") + "ve reader";
    // "012" written with U+0660..U+0662 ARABIC-INDIC DIGIT ZERO..TWO.
    String arabicIndic = ch("0660") + ch("0661") + ch("0662");

    table("default -- \\w, \\d and \\s are ASCII:", "\\w", "\\d", "\\s");
    table("(?U), which is Pattern.UNICODE_CHARACTER_CLASS:", "(?U)\\w", "(?U)\\d", "(?U)\\s");
    table("the \\p{...} properties, which never needed (?U):",
        "\\p{L}", "\\p{Nd}", "\\p{IsWhite_Space}");

    System.out.println("\\b\\w+\\b over 'na' U+00EF 've reader' -- how many words?");
    String[][] patterns = {
        { "\\b\\w+\\b", "\\b\\w+\\b" },
        { "(?U)\\b\\w+\\b", "(?U)\\b\\w+\\b" },
        { "\\b[\\p{L}\\p{N}_]+\\b", "\\b[\\p{L}\\p{N}_]+\\b" },
    };
    for (String[] p : patterns) {
        Matcher m = Pattern.compile(p[1]).matcher(subject);
        List<String> found = new ArrayList<>();
        while (m.find()) {
            found.add(esc(m.group()));
        }
        System.out.println("  " + pad(p[0], 20) + " -> " + found.size() + "   " + String.join(" ", found));
    }
    System.out.println();

    System.out.println("\\d and the number that follows it (subject is U+0660 U+0661 U+0662):");
    System.out.println("  \\d+                   -> " + hit("\\d+", arabicIndic));
    System.out.println("  (?U)\\d+               -> " + hit("(?U)\\d+", arabicIndic));
    System.out.println("  \\p{Nd}+               -> " + hit("\\p{Nd}+", arabicIndic));
    try {
        System.out.println("  Integer.parseInt()    -> " + Integer.parseInt(arabicIndic));
    } catch (NumberFormatException e) {
        System.out.println("  Integer.parseInt()    -> throws " + e.getClass().getSimpleName());
    }
    try {
        System.out.println("  Double.parseDouble()  -> " + Double.parseDouble(arabicIndic));
    } catch (NumberFormatException e) {
        System.out.println("  Double.parseDouble()  -> throws " + e.getClass().getSimpleName());
    }
}
