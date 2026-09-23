// The Java column of tools/kwprobe/run.py. One cell per row on stdout.
//
// Run as `java Probe.java rows` -- the source launcher, Java 25.
// Matcher.replaceFirst is the replace-first question; Pattern.split with a
// limit of -1 keeps trailing empty pieces, which every other column also does.
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Probe {
    static String decode(String s) {
        StringBuilder out = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 1 < s.length()) {
                char n = s.charAt(i + 1);
                if (n == 'n') { out.append('\n'); i++; continue; }
                if (n == 'r') { out.append('\r'); i++; continue; }
                if (n == 't') { out.append('\t'); i++; continue; }
                if (n == '\\') { out.append('\\'); i++; continue; }
                if (n == 'u' && i + 2 < s.length() && s.charAt(i + 2) == '{') {
                    int j = s.indexOf('}', i);
                    out.appendCodePoint(Integer.parseInt(s.substring(i + 3, j), 16));
                    i = j; continue;
                }
            }
            out.append(c);
        }
        return out.toString();
    }

    static String encode(String s) {
        if (s.isEmpty()) return "\"\"";
        StringBuilder out = new StringBuilder();
        s.codePoints().forEach(o -> {
            if (o == '\\') out.append("\\\\");
            else if (o == '\n') out.append("\\n");
            else if (o == '\r') out.append("\\r");
            else if (o == '\t') out.append("\\t");
            else if (o < 0x20 || o > 0x7e) out.append("\\u{").append(Integer.toHexString(o).toUpperCase()).append('}');
            else out.appendCodePoint(o);
        });
        return out.toString();
    }

    public static void main(String[] args) throws Exception {
        for (String raw : Files.readAllLines(Path.of(args[0]), StandardCharsets.UTF_8)) {
            String line = raw.strip();
            if (line.isEmpty() || line.startsWith("#")) continue;
            String[] f = line.split(" :: ");
            for (int i = 0; i < f.length; i++) f[i] = f[i].strip();
            String pattern = f[1];
            String subject = f.length > 2 ? decode(f[2]) : null;
            String replace = null;
            boolean split = false, skip = false;
            for (int i = 3; i < f.length; i++) {
                String o = f[i];
                if (o.startsWith("replace=")) replace = decode(o.substring(8));
                else if (o.equals("split")) split = true;
                else if (o.startsWith("skip=") && List.of(o.substring(5).split(",")).contains("java")) skip = true;
            }
            if (skip) { System.out.println("n/a"); continue; }
            Pattern p;
            try { p = Pattern.compile(pattern); } catch (Exception e) { System.out.println("-"); continue; }
            if (subject == null) { System.out.println("ok"); continue; }
            try {
                if (replace != null) {
                    Matcher m = p.matcher(subject);
                    if (!m.find()) { System.out.println("no"); continue; }
                    System.out.println(encode(m.replaceFirst(replace)));
                } else if (split) {
                    List<String> parts = new ArrayList<>();
                    for (String piece : p.split(subject, -1)) parts.add(piece.isEmpty() ? "" : encode(piece));
                    System.out.println("[" + String.join(",", parts) + "]");
                } else {
                    Matcher m = p.matcher(subject);
                    System.out.println(m.find() ? encode(m.group()) : "no");
                }
            } catch (Exception e) { System.out.println("err"); }
        }
    }
}
