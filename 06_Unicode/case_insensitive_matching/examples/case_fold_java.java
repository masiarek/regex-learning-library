// What CASE_INSENSITIVE folds in java.util.regex -- and what UNICODE_CASE adds.
//
// A compact source file (Java 25), run by the source launcher. Characters are
// built from code points with Character.toString and named by code point, so
// the output is ASCII whatever the platform encoding is.

import java.util.Locale;
import java.util.regex.Pattern;

static final String KELVIN = Character.toString(0x212A);
static final String LONG_S = Character.toString(0x017F);
static final String SHARP_S = Character.toString(0x00DF);
static final String CAP_SHARP_S = Character.toString(0x1E9E);
static final String DOTLESS_I = Character.toString(0x0131);
static final String DOTTED_I = Character.toString(0x0130);
static final String DOT_ABOVE = Character.toString(0x0307);

static final int CI = Pattern.CASE_INSENSITIVE;
static final int CIU = Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE;

static String yn(boolean hit) {
    return hit ? "yes" : "no";
}

static String hit(String pattern, String subject, int flags) {
    return yn(Pattern.compile("^(?:" + pattern + ")$", flags).matcher(subject).matches());
}

static String codePoints(String s) {
    StringBuilder out = new StringBuilder();
    s.codePoints().forEach(cp -> out.append(out.isEmpty() ? "" : " ").append(String.format("U+%04X", cp)));
    return out.toString();
}

void main() {
    String[][] probes = {
        {"k", "k", "U+004B LATIN CAPITAL LETTER K", "K"},
        {"k", "k", "U+212A KELVIN SIGN", KELVIN},
        {"s", "s", "U+017F LATIN SMALL LETTER LONG S", LONG_S},
        {"U+00DF", SHARP_S, "U+1E9E LATIN CAPITAL LETTER SHARP S", CAP_SHARP_S},
        {"U+1E9E", CAP_SHARP_S, "U+00DF LATIN SMALL LETTER SHARP S", SHARP_S},
        {"ss", "ss", "U+00DF LATIN SMALL LETTER SHARP S", SHARP_S},
        {"[k]", "[k]", "U+212A KELVIN SIGN", KELVIN},
        {"[a-z]", "[a-z]", "U+212A KELVIN SIGN", KELVIN},
        {"i", "i", "U+0131 LATIN SMALL LETTER DOTLESS I", DOTLESS_I},
        {"i", "i", "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I},
        {"i U+0307", "i" + DOT_ABOVE, "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I},
    };

    System.out.println("does (?i) match?          java.util.regex, anchored");
    System.out.printf("%-9s %-46s %-7s%s%n", "pattern", "subject", "(?i)", "(?iu)");
    for (String[] p : probes) {
        System.out.printf("%-9s %-46s %-7s%s%n", p[0], p[2], hit(p[1], p[3], CI), hit(p[1], p[3], CIU));
    }

    System.out.println();
    System.out.println("does (?i) fold the BACKREFERENCE comparison too?");
    System.out.printf("%-12s vs 'a' + U+0041            %s%n", "(?i)(a)\\1",
        yn(Pattern.compile("(a)\\1", CI).matcher("aA").find()));
    System.out.printf("%-12s vs 'k' + U+212A            %s%n", "(?iu)(k)\\1",
        yn(Pattern.compile("(k)\\1", CIU).matcher("k" + KELVIN).find()));

    System.out.println();
    System.out.println("one program, two answers about the same pair");
    row("toUpperCase(U+00DF, ROOT) is 'SS'", SHARP_S.toUpperCase(Locale.ROOT).equals("SS"), hit("SS", SHARP_S, CIU));
    row("equalsIgnoreCase(U+00DF, 'ss')", SHARP_S.equalsIgnoreCase("ss"), hit("ss", SHARP_S, CIU));
    row("equalsIgnoreCase(U+212A, 'k')", KELVIN.equalsIgnoreCase("k"), hit("k", KELVIN, CIU));
    row("toLowerCase(U+1E9E, ROOT) is U+00DF", CAP_SHARP_S.toLowerCase(Locale.ROOT).equals(SHARP_S), hit(SHARP_S, CAP_SHARP_S, CIU));

    System.out.println();
    System.out.println("how one character is folded onto another: lower(upper(cp))");
    for (int cp : new int[] {0x00DF, 0x1E9E, 0x0131, 0x0130}) {
        System.out.printf("  U+%04X  toUpperCase %s  then toLowerCase %s%n", cp,
            codePoints(Character.toString(Character.toUpperCase(cp))),
            codePoints(Character.toString(Character.toLowerCase(Character.toUpperCase(cp)))));
    }

    System.out.println();
    System.out.println("the locale the regex engine refuses to have");
    System.out.printf("  toLowerCase('I', Locale.ROOT)          %s%n", codePoints("I".toLowerCase(Locale.ROOT)));
    System.out.printf("  toLowerCase('I', Locale tr)            %s%n",
        codePoints("I".toLowerCase(Locale.forLanguageTag("tr"))));
    System.out.printf("  toUpperCase('i', Locale tr)            %s%n",
        codePoints("i".toUpperCase(Locale.forLanguageTag("tr"))));
    System.out.printf("  (?iu)i vs U+0131                       %s%n", hit("i", DOTLESS_I, CIU));
    System.out.printf("  (?iu)I vs U+0131                       %s%n", hit("I", DOTLESS_I, CIU));
}

static void row(String label, boolean strAnswer, String reAnswer) {
    System.out.printf("  %-38s%-8s regex (?iu): %s%n", label, strAnswer, reAnswer);
}
