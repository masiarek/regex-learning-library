#!/usr/bin/env bash
# Hand the same fourteen spellings to six engines and print who compiles what.
#
# Every cell is one engine being handed one pattern. "yes" means it compiled --
# nothing more. The second table is the follow-up question that matters: of the
# engines that compile \p{Alpha}, do they all mean the same thing by it?
#
# Each engine's helper reads one pattern per line and prints three words:
#   <compiled?> <matches U+0041?> <matches U+03B1?> <a note from the engine>
# so one pass answers every table below. No engine's error message is printed: node,
# ruby and perl reword theirs between releases, and this key has to hold on two
# different machines.
set -u

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/spellings" <<'SPELL'
\p{L}
\pL
\p{Lu}
\p{Nd}
\p{P}
\p{Greek}
\p{Script=Greek}
\p{sc=Greek}
\p{IsGreek}
\p{Alphabetic}
\p{IsAlphabetic}
\p{White_Space}
\p{Alpha}
[\p{L}\p{Nd}]
\X
SPELL

# macOS still ships Ruby 2.6 at /usr/bin/ruby; prefer a modern one if present.
RUBY=$(command -v ruby)
for candidate in /usr/local/opt/ruby/bin/ruby /opt/homebrew/opt/ruby/bin/ruby; do
  [ -x "$candidate" ] && RUBY=$candidate && break
done

cat > "$tmp/probe.py" <<'PY'
import re, sys
for line in sys.stdin.read().splitlines():
    try:
        p = re.compile("^(?:" + line + ")$")
    except re.error:
        print("no - -")
        continue
    hit = lambda cp: "yes" if p.match(chr(cp)) else "no"
    print("yes", hit(0x0041), hit(0x03B1))
PY

cat > "$tmp/probe.pl" <<'PL'
no warnings;
while (my $line = <STDIN>) {
    chomp $line;
    my $re = eval { qr/\A(?:$line)\z/ };
    if (!$re) { print "no - -\n"; next; }
    printf "yes %s %s\n", (chr(0x0041) =~ $re ? "yes" : "no"), (chr(0x03B1) =~ $re ? "yes" : "no");
}
PL

cat > "$tmp/probe.js" <<'JS'
const lines = require("fs").readFileSync(0, "utf8").split("\n").filter((s) => s.length > 0);
for (const spelling of lines) {
  let re;
  try { re = new RegExp("^(?:" + spelling + ")$", "u"); } catch { console.log("no - -"); continue; }
  const hit = (cp) => (re.test(String.fromCodePoint(cp)) ? "yes" : "no");
  console.log("yes", hit(0x0041), hit(0x03B1));
}
JS

cat > "$tmp/probe.rb" <<'RB'
# Ruby warns about \pL rather than refusing it, and a warning carries a file
# name and a line number -- neither of which belongs in an answer key. Capture
# it as a flag instead.
WARNED = []
module Warning
  def self.warn(message, category: nil)
    WARNED << message
  end
end

STDIN.read.split("\n").each do |spelling|
  WARNED.clear
  begin
    re = Regexp.new("\\A(?:" + spelling + ")\\z")
  rescue StandardError
    puts "no - - clean"
    next
  end
  hit = ->(cp) { re.match?(cp.chr(Encoding::UTF_8)) ? "yes" : "no" }
  puts "yes #{hit.call(0x0041)} #{hit.call(0x03B1)} #{WARNED.empty? ? "clean" : "warned"}"
end
RB

cat > "$tmp/Sp.java" <<'JAVA'
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

public class Sp {
  static String hit(Pattern p, int cp) {
    return p.matcher(new String(Character.toChars(cp))).matches() ? "yes" : "no";
  }

  public static void main(String[] args) throws Exception {
    BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
    String line;
    while ((line = in.readLine()) != null) {
      try {
        Pattern p = Pattern.compile("^(?:" + line + ")$");
        System.out.println("yes " + hit(p, 0x0041) + " " + hit(p, 0x03B1));
      } catch (PatternSyntaxException e) {
        System.out.println("no - -");
      }
    }
  }
}
JAVA

cat > "$tmp/probe.go" <<'GO'
package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"regexp/syntax"
)

func hit(re *regexp.Regexp, cp rune) string {
	if re.MatchString(string(cp)) {
		return "yes"
	}
	return "no"
}

func main() {
	in := bufio.NewScanner(os.Stdin)
	for in.Scan() {
		re, err := regexp.Compile("^(?:" + in.Text() + ")$")
		if err != nil {
			code := "error"
			if e, ok := err.(*syntax.Error); ok {
				code = string(e.Code)
			}
			fmt.Println("no - -", code)
			continue
		}
		fmt.Println("yes", hit(re, 0x0041), hit(re, 0x03B1), "ok")
	}
}
GO

python3 "$tmp/probe.py"  < "$tmp/spellings" > "$tmp/python"
perl   "$tmp/probe.pl"   < "$tmp/spellings" > "$tmp/perl"
node   "$tmp/probe.js"   < "$tmp/spellings" > "$tmp/node"
"$RUBY" "$tmp/probe.rb"  < "$tmp/spellings" > "$tmp/ruby"
java   "$tmp/Sp.java"    < "$tmp/spellings" > "$tmp/java"
"${GO:-go}" run "$tmp/probe.go" < "$tmp/spellings" > "$tmp/go"

for engine in python perl node ruby java go; do
  cut -d' ' -f1 "$tmp/$engine" > "$tmp/compiled_$engine"
done

printf '%-28s %-7s %-6s %-7s %-6s %-6s %s\n' "does it COMPILE?" python perl "node u" ruby java go
paste -d'|' "$tmp/spellings" "$tmp/compiled_python" "$tmp/compiled_perl" "$tmp/compiled_node" \
            "$tmp/compiled_ruby" "$tmp/compiled_java" "$tmp/compiled_go" |
while IFS='|' read -r spelling py pl js rb jv go; do
  printf '%-28s %-7s %-6s %-7s %-6s %-6s %s\n' "$spelling" "$py" "$pl" "$js" "$rb" "$jv" "$go"
done

echo
echo "and where it compiles, does it MEAN what it says?"
echo "(the two answers are U+0041 and U+03B1; a dash is: did not compile)"
printf '%-14s %-9s %-9s %-9s %-9s %-9s %s\n' spelling python perl "node u" ruby java go
for spelling in '\pL' '\p{Alpha}' '\p{Greek}'; do
  row=$(/usr/bin/grep -n -x -F "$spelling" "$tmp/spellings" | cut -d: -f1)
  set --
  for engine in python perl node ruby java go; do
    set -- "$@" "$(/usr/bin/sed -n "${row}p" "$tmp/$engine" | cut -d' ' -f2,3)"
  done
  printf '%-14s %-9s %-9s %-9s %-9s %-9s %s\n' "$spelling" "$@"
done

echo
echo "compiled, but ruby warned while doing it:"
paste -d'|' "$tmp/spellings" "$tmp/ruby" |
while IFS='|' read -r spelling answer; do
  case "$answer" in
    *" warned") echo "  $spelling" ;;
  esac
done

echo
echo "and what go calls a property it has never heard of:"
cut -d' ' -f4- "$tmp/go" | /usr/bin/grep -v '^ok$' | sort -u | /usr/bin/sed 's/^/  /'
