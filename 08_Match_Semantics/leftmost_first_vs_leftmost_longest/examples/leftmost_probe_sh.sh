#!/usr/bin/env bash
# Hand five Perl-family engines the same pattern and the same subject, and
# print what each one calls "the match".
#
# The point of the table is that there is nothing to notice in it. Five engines,
# five different implementations, one answer per row -- and every answer is the
# first alternative that works at the earliest position, never the longest.
set -u

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/M.java" <<'JAVA'
public class M {
  public static void main(String[] args) {
    java.util.regex.Matcher m =
        java.util.regex.Pattern.compile(args[1]).matcher(args[2]);
    if (!m.find()) { System.out.println("-"); return; }
    if (args[0].equals("whole")) { System.out.println(m.group()); return; }
    StringBuilder b = new StringBuilder("whole=" + m.group());
    for (int i = 1; i <= m.groupCount(); i++) {
      b.append(" g").append(i).append("=").append(m.group(i) == null ? "-" : m.group(i));
    }
    System.out.println(b);
  }
}
JAVA

# macOS still ships Ruby 2.6 at /usr/bin/ruby; prefer a modern one if present.
RUBY=$(command -v ruby)
for candidate in /usr/local/opt/ruby/bin/ruby /opt/homebrew/opt/ruby/bin/ruby; do
  [ -x "$candidate" ] && RUBY=$candidate && break
done

# $1 pattern, $2 subject -> the text of the first match, or "-".
whole_python() { python3 -c 'import re,sys
m = re.search(sys.argv[1], sys.argv[2])
print(m.group(0) if m else "-")' "$1" "$2"; }
whole_perl()   { perl -e 'print $ARGV[1] =~ /$ARGV[0]/ ? "$&\n" : "-\n"' "$1" "$2"; }
whole_node()   { node -e 'const m = process.argv[2].match(new RegExp(process.argv[1]));
console.log(m ? m[0] : "-")' "$1" "$2"; }
whole_ruby()   { "$RUBY" -e 'm = Regexp.new(ARGV[0]).match(ARGV[1]); puts(m ? m[0] : "-")' "$1" "$2"; }
whole_java()   { java "$tmp/M.java" whole "$1" "$2"; }

printf '%-22s %-9s %-7s %-6s %-6s %-6s %s\n' \
  "pattern" "subject" "python" "perl" "node" "ruby" "java"
while IFS=';' read -r pattern subject; do
  printf '%-22s %-9s %-7s %-6s %-6s %-6s %s\n' "$pattern" "$subject" \
    "$(whole_python "$pattern" "$subject")" "$(whole_perl "$pattern" "$subject")" \
    "$(whole_node "$pattern" "$subject")" "$(whole_ruby "$pattern" "$subject")" \
    "$(whole_java "$pattern" "$subject")"
done <<'CASES'
a|ab;ab
ab|a;ab
[0-9]+|[0-9]+\.[0-9]+;v 3.14 w
[0-9]+\.[0-9]+|[0-9]+;v 3.14 w
CASES

# And the subexpressions, for comparison with the POSIX engine in C.
echo
echo "(a|ab)(c|bcd)(d*) on abcd"
P='(a|ab)(c|bcd)(d*)'
S='abcd'
printf '%-7s %s\n' python "$(python3 -c 'import re,sys
m = re.search(sys.argv[1], sys.argv[2])
print("whole=%s g1=%s g2=%s g3=%s" % (m.group(0), m.group(1), m.group(2), m.group(3)))' "$P" "$S")"
printf '%-7s %s\n' perl "$(perl -e '$ARGV[1] =~ /$ARGV[0]/;
print "whole=$& g1=$1 g2=$2 g3=$3\n"' "$P" "$S")"
printf '%-7s %s\n' node "$(node -e 'const m = process.argv[2].match(new RegExp(process.argv[1]));
console.log(`whole=${m[0]} g1=${m[1]} g2=${m[2]} g3=${m[3]}`)' "$P" "$S")"
printf '%-7s %s\n' ruby "$("$RUBY" -e 'm = Regexp.new(ARGV[0]).match(ARGV[1])
puts "whole=#{m[0]} g1=#{m[1]} g2=#{m[2]} g3=#{m[3]}"' "$P" "$S")"
printf '%-7s %s\n' java "$(java "$tmp/M.java" groups "$P" "$S")"
