#!/usr/bin/env bash
# Every host language has a function that turns text into a pattern that
# matches exactly that text. They do not agree about which characters need a
# backslash, and two of them do not use backslashes at all.
set -u
text='a.b*c[d]{e}$ f'
printf '%-8s %s\n' input "$text"
printf '%-8s %s\n' python  "$(python3 -c 'import re,sys; print(re.escape(sys.argv[1]))' "$text")"
printf '%-8s %s\n' perl    "$(perl -e 'print quotemeta($ARGV[0])' "$text")"
RUBY=$(command -v ruby)
for candidate in /usr/local/opt/ruby/bin/ruby /opt/homebrew/opt/ruby/bin/ruby; do
  [ -x "$candidate" ] && RUBY=$candidate && break
done
printf '%-8s %s\n' ruby    "$("$RUBY" -e 'print Regexp.escape(ARGV[0])' "$text")"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/Q.java" <<'JAVA'
public class Q { public static void main(String[] a) { System.out.println(java.util.regex.Pattern.quote(a[0])); } }
JAVA
printf '%-8s %s\n' java    "$(java "$tmp/Q.java" "$text")"
cat > "$tmp/q.go" <<'GO'
package main
import ("fmt"; "os"; "regexp")
func main() { fmt.Println(regexp.QuoteMeta(os.Args[1])) }
GO
printf '%-8s %s\n' go      "$(go run "$tmp/q.go" "$text")"
printf '%-8s %s\n' rust    "$(cargo run --locked --quiet --manifest-path ../../../rust-demo/Cargo.toml --bin escape -- "$text")"
