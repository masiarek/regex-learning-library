// How much work is a greedy quantifier, and how much is a lazy one?
//
// java.util.regex matches any CharSequence, so the subject can count how many
// times the engine asks for a character. That is a real measurement of a real
// engine -- not a timing, which would depend on the machine and could never be
// an answer key.
//
// Read `reads` as "characters the engine looked at". The numbers are structural:
// double the subject and the linear ones double with it.

import java.util.regex.Matcher;
import java.util.regex.Pattern;

class GreedyLazyCost {

    /** A subject that remembers how often it was asked for a character. */
    static final class Counted implements CharSequence {
        private final String text;
        int reads;

        Counted(String text) {
            this.text = text;
        }

        public int length() {
            return text.length();
        }

        public char charAt(int i) {
            reads++;
            return text.charAt(i);
        }

        public CharSequence subSequence(int from, int to) {
            return text.subSequence(from, to);
        }

        public String toString() {
            return text;
        }
    }

    static void row(String pattern, String subject) {
        Counted counted = new Counted(subject);
        Matcher m = Pattern.compile(pattern).matcher(counted);
        boolean found = m.find();
        String where = found ? m.start() + ".." + m.end() : "no match";
        System.out.printf("  %-11s match %-9s reads %d%n", pattern, where, counted.reads);
    }

    public static void main(String[] args) {
        String late = "x".repeat(100) + "END";
        String early = "END" + "x".repeat(100);
        String longer = "x".repeat(200) + "END";

        System.out.println("characters the engine read, counted by the subject itself");

        System.out.println("subject: 100 x, then END   (the match ends at the far end)");
        row("^.*END$", late);
        row("^.*?END$", late);
        row("^[^E]*END$", late);

        System.out.println("subject: END, then 100 x   (the match ends at the near end)");
        row("^.*END", early);
        row("^.*?END", early);
        row("^[^E]*END", early);

        System.out.println("subject: 200 x, then END   (the same shape, twice as long)");
        row("^.*END$", longer);
        row("^.*?END$", longer);
        row("^[^E]*END$", longer);

        System.out.println("subject: <b>bold</b>");
        row("<.+>", "<b>bold</b>");
        row("<.+?>", "<b>bold</b>");
        row("<[^>]+>", "<b>bold</b>");

        System.out.println("subject: aaa");
        row("a+", "aaa");
        row("a+?", "aaa");
        row("a*?", "aaa");
        row("a{1,3}?", "aaa");
    }
}
