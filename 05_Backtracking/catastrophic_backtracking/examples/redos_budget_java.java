// Java 25 does not explode on any of the shapes this page is about, and that is
// worth measuring rather than assuming: the advisories say otherwise, and so
// did this lesson's first draft.
//
// There is no clock here at all. The subject is wrapped in a CharSequence that
// counts every character the engine reads and abandons the match when a fixed
// budget runs out, so "answered" and "still searching" are properties of the
// search itself and not of the machine running it.

import java.util.regex.Pattern;

class RedosBudget {

    static final long BUDGET = 20_000_000L;

    static final String EMAIL =
        "^([a-zA-Z0-9_\\.\\-])+\\@(([a-zA-Z0-9\\-])+\\.)+([a-zA-Z]{2,4})+$";
    static final String EMAIL_FIXED =
        "^[a-zA-Z0-9_.-]+@([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,4}$";

    static String probe(String pattern, String subject) {
        try {
            boolean hit = Pattern.compile(pattern).matcher(new Budget(subject, BUDGET)).matches();
            return hit ? "match" : "no match";
        } catch (Budget.Exhausted spent) {
            return "still searching";
        }
    }

    static void table(String title, String[][] rows) {
        System.out.println(title);
        for (String[] row : rows) {
            String pattern = row[0], shown = row[1], subject = row[2], described = row[3];
            System.out.printf("  %-24s %-22s %s%n",
                shown == null ? pattern : shown, described, probe(pattern, subject));
        }
    }

    public static void main(String[] args) {
        String hostile = "a".repeat(120) + "!";     // one character that cannot match
        String blanks = " ".repeat(120) + "!";
        String mailHostile = "a@a." + "a".repeat(120) + "!";
        String megabyte = "a".repeat(1_000_000) + "!";

        System.out.println("the budget is " + BUDGET + " character reads per match; "
            + "running out is reported as \"still searching\".");
        System.out.println();

        table("patterns with no backreference, java:", new String[][] {
            { "^(a+)+$", null, hostile, "120 a's then '!'" },
            { "^(a|a)*$", null, hostile, "120 a's then '!'" },
            { "^(\\s*|\\t)+$", null, blanks, "120 spaces then '!'" },
            { "^(\\w+\\s?)*$", null, hostile, "120 a's then '!'" },
            { "^([a-z]{2,4})+$", null, hostile, "120 a's then '!'" },
            { EMAIL, "the email regex", mailHostile, "a@a. 120 a's then '!'" },
        });

        System.out.println();
        table("the same patterns, on a field a user filled with a megabyte:", new String[][] {
            { "^(a+)+$", null, megabyte, "1000000 a's then '!'" },
            { "^(?>a+)+$", null, megabyte, "1000000 a's then '!'" },
            { "^a+$", null, megabyte, "1000000 a's then '!'" },
            { EMAIL_FIXED, "the email regex, fixed", "a@a." + megabyte, "a@a. then a megabyte" },
        });

        System.out.println();
        System.out.println("and the control, so the budget above is not mistaken for a guarantee:");
        System.out.printf("  %-24s %-22s %s%n", "^(a+)+\\1$", "28 a's then '!'",
            probe("^(a+)+\\1$", "a".repeat(28) + "!"));
    }
}

/** The subject, with a ration. Every charAt the engine spends is one off the budget. */
final class Budget implements CharSequence {

    static final class Exhausted extends RuntimeException {
        Exhausted() { super(null, null, false, false); }
    }

    private final CharSequence text;
    private long left;

    Budget(CharSequence text, long budget) {
        this.text = text;
        this.left = budget;
    }

    @Override public int length() { return text.length(); }

    @Override public char charAt(int index) {
        if (--left < 0) throw new Exhausted();
        return text.charAt(index);
    }

    @Override public CharSequence subSequence(int start, int end) {
        return text.subSequence(start, end);
    }

    @Override public String toString() { return text.toString(); }
}
