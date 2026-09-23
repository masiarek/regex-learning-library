// java.util.regex has \G too, and Matcher.find() keeps the position it needs.
// The loop is the same shape as Perl's: every token must begin where the
// previous one ended, so a character no alternative accepts is an error at a
// known offset rather than something find() quietly skips past.
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

void main() {
    String src = "x = 42 ? y7";
    Pattern token = Pattern.compile("\\G\\s*(\\d+|[A-Za-z_]\\w*|[=+])");
    Matcher m = token.matcher(src);
    List<String> out = new ArrayList<>();
    int at = 0;
    while (at < src.length()) {
        if (m.find(at) && m.start() == at) {
            out.add(m.group(1));
            at = m.end();
        } else {
            out.add("ERROR at " + at);
            break;
        }
    }
    IO.println("with \\G:    " + String.join(" ", out));

    Pattern loose = Pattern.compile("\\d+|[A-Za-z_]\\w*|[=+]");
    Matcher l = loose.matcher(src);
    List<String> got = new ArrayList<>();
    while (l.find()) got.add(l.group());
    IO.println("without \\G: " + String.join(" ", got));
}
