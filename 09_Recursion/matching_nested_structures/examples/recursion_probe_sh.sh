#!/usr/bin/env bash
# Hand five engines the six spellings of "recurse", and print what they answer.
#
# There are two dialects. Perl and PCRE2 spell recursion (?R), (?1), (?&name).
# Onigmo -- which is Ruby -- spells it \g<0>, \g<1>, \g<name>. A probe that only
# asks for (?R) concludes that Ruby has no recursion, which is wrong.
#
# The second table is the one that matters, because "it compiled" is not the
# same claim as "it recurses": one engine here compiles \g<0> and then matches
# the literal text g<0>.
set -u

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/R.java" <<'JAVA'
public class R {
  public static void main(String[] args) {
    try { java.util.regex.Pattern.compile(args[0]); System.out.println("yes"); }
    catch (Exception e) { System.out.println("no"); }
  }
}
JAVA

# macOS still ships Ruby 2.6 at /usr/bin/ruby; prefer a modern one if present.
RUBY=$(command -v ruby)
for candidate in /usr/local/opt/ruby/bin/ruby /opt/homebrew/opt/ruby/bin/ruby; do
  [ -x "$candidate" ] && RUBY=$candidate && break
done

probe_python() { python3 -c 'import re,sys
try:
    re.compile(sys.argv[1]); print("yes")
except re.error:
    print("no")' "$1"; }
probe_perl()   { perl -e 'eval { qr/$ARGV[0]/ }; print $@ ? "no" : "yes", "\n"' "$1"; }
probe_node()   { node -e 'try { new RegExp(process.argv[1]); console.log("yes") } catch { console.log("no") }' "$1"; }
probe_ruby()   { "$RUBY" -e 'begin; Regexp.new(ARGV[0]); puts "yes"; rescue; puts "no"; end' "$1"; }
probe_java()   { java "$tmp/R.java" "$1"; }

printf '%-26s %-7s %-6s %-6s %-6s %-6s\n' "does it COMPILE?" "python" "perl" "node" "ruby" "java"
while IFS='|' read -r name pattern; do
  printf '%-26s %-7s %-6s %-6s %-6s %-6s\n' "$name" \
    "$(probe_python "$pattern")" "$(probe_perl "$pattern")" "$(probe_node "$pattern")" \
    "$(probe_ruby "$pattern")" "$(probe_java "$pattern")"
done <<'PATTERNS'
(?R)                      |\((?:[^()]|(?R))*\)
(?1)                      |(\((?:[^()]|(?1))*\))
(?&p), with (?<p>...)     |(?<p>\((?:[^()]|(?&p))*\))
(?&p), with (?P<p>...)    |(?P<p>\((?:[^()]|(?&p))*\))
\g<0>                     |\((?:[^()]|\g<0>)*\)
\g<p>, with (?<p>...)     |(?<p>\((?:[^()]|\g<p>)*\))
PATTERNS

# Now the only question that counts: hand each engine ITS OWN spelling, anchored
# to the whole subject, and ask whether it matches. n/a means the engine has no
# recursion construct to try.
echo
echo "does that engine's OWN anchored recursive pattern MATCH?"
printf '%-12s %-7s %-6s %-6s %-6s %-6s\n' "subject" "python" "perl" "node" "ruby" "java"

match_perl() { perl -e 'print(($ARGV[0] =~ /^(\((?:[^()]|(?1))*\))$/) ? "yes" : "no")' "$1"; }
match_node() { node -e 'process.stdout.write(new RegExp(String.raw`^\((?:[^()]|\g<0>)*\)$`).test(process.argv[1]) ? "yes" : "no")' "$1"; }
match_ruby() { "$RUBY" -e 'print((ARGV[0] =~ /\A(\((?:[^()]|\g<1>)*\))\z/) ? "yes" : "no")' "$1"; }

for subject in '((a)(b))' '(ab)' '(a(b)c'; do
  printf '%-12s %-7s %-6s %-6s %-6s %-6s\n' "$subject" \
    "n/a" "$(match_perl "$subject")" "$(match_node "$subject")" "$(match_ruby "$subject")" "n/a"
done

# Node answered "no" to the nested subject while compiling the pattern happily.
# The reason: outside unicode mode, \g is an IDENTITY ESCAPE -- \g<0> is the
# four literal characters g<0>. Proof: swap \g<0> for a plain g<0> and nothing
# changes.
echo
echo "in node, is \\g<0> recursion or the literal text g<0> ?"
printf '%-12s %-12s %s\n' "subject" "with \\g<0>" "with literal g<0>"
for subject in '((a)(b))' '(g<0>)' '(ab)'; do
  printf '%-12s %-12s %s\n' "$subject" \
    "$(node -e 'process.stdout.write(new RegExp(String.raw`^\((?:[^()]|\g<0>)*\)$`).test(process.argv[1]) ? "yes" : "no")' "$subject")" \
    "$(node -e 'process.stdout.write(new RegExp(String.raw`^\((?:[^()]|g<0>)*\)$`).test(process.argv[1]) ? "yes" : "no")' "$subject")"
done
echo "under the u flag, node rejects \\g<0> outright:" \
     "$(node -e 'try { new RegExp(String.raw`\g<0>`, "u"); process.stdout.write("compiled") } catch { process.stdout.write("refused") }')"
