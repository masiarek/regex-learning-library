#!/usr/bin/env bash
# Hand the same pattern and the same subject to five engines, and print what
# each one answers. Nothing here is read from a documentation page.
#
#   yes  the engine compiled the pattern and found a match
#   no   the engine compiled the pattern and found none
#   -    the engine REFUSED to compile the pattern
#
# So a column of dashes is how "this engine has no such feature" looks when you
# ask by running rather than by reading.
set -u

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/A.java" <<'JAVA'
public class A {
  public static void main(String[] args) {
    try {
      java.util.regex.Pattern p = java.util.regex.Pattern.compile(args[0]);
      System.out.println(p.matcher(args[1]).find() ? "yes" : "no");
    } catch (Exception e) { System.out.println("-"); }
  }
}
JAVA

# macOS still ships Ruby 2.6 at /usr/bin/ruby; prefer a modern one if present.
RUBY=$(command -v ruby)
for candidate in /usr/local/opt/ruby/bin/ruby /opt/homebrew/opt/ruby/bin/ruby; do
  [ -x "$candidate" ] && RUBY=$candidate && break
done

probe_python() { python3 -c 'import re, sys
try:
    found = re.search(sys.argv[1], sys.argv[2])
except re.error:
    print("-")
else:
    print("yes" if found else "no")' "$1" "$2"; }

probe_perl() { perl -e 'my $re = eval { qr/$ARGV[0]/ };
print defined $re ? (($ARGV[1] =~ $re) ? "yes\n" : "no\n") : "-\n"' "$1" "$2"; }

probe_node() { node -e 'let re;
try { re = new RegExp(process.argv[1]) } catch (e) { console.log("-"); process.exit(0) }
console.log(re.test(process.argv[2]) ? "yes" : "no")' "$1" "$2"; }

probe_ruby() { "$RUBY" -e 'begin
  re = Regexp.new(ARGV[0])
rescue RegexpError
  puts "-"
else
  puts((ARGV[1] =~ re) ? "yes" : "no")
end' "$1" "$2"; }

probe_java() { java "$tmp/A.java" "$1" "$2"; }

row() {
  printf '%-22s %-13s %-7s %-6s %-6s %-6s %s\n' "$1" "$2" \
    "$(probe_python "$1" "$2")" "$(probe_perl "$1" "$2")" "$(probe_node "$1" "$2")" \
    "$(probe_ruby "$1" "$2")" "$(probe_java "$1" "$2")"
}

printf '%-22s %-13s %-7s %-6s %-6s %-6s %s\n' \
  "pattern" "subject" "python" "perl" "node" "ruby" "java"
while IFS='|' read -r pattern subject; do
  row "$pattern" "$subject"
done <<'CASES'
a+a|aa
a++a|aa
(?>a+)a|aa
a++b|aab
(?>a+)b|aab
^[\w.]+\.com$|example.com
^[\w.]++\.com$|example.com
(?=(a+))\1a|aa
(?=(a+))\1b|aab
CASES
