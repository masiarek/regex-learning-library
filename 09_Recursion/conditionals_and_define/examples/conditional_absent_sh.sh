#!/usr/bin/env bash
# The three engines with no conditionals at all: hand each the same pattern and
# print whether it compiled.
#
# One word per engine, chosen here. Their own messages say four different things
# and get reworded between releases; "refused at compile time" does not.
set -u

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# ^(<)?\w+(?(1)>)$ -- an optional '<' that makes the closing '>' mandatory.
PATTERN='^(<)?\w+(?(1)>)$'

cat > "$tmp/P.java" <<'JAVA'
public class P {
  public static void main(String[] args) {
    try { java.util.regex.Pattern.compile(args[0]); System.out.println("compiled"); }
    catch (Exception e) { System.out.println("refused at compile time"); }
  }
}
JAVA

cat > "$tmp/probe.go" <<'GO'
package main

import (
	"fmt"
	"os"
	"regexp"
)

func main() {
	if _, err := regexp.Compile(os.Args[1]); err != nil {
		fmt.Println("refused at compile time")
	} else {
		fmt.Println("compiled")
	}
}
GO

printf '%-12s %s\n' javascript \
  "$(node -e 'try { new RegExp(process.argv[1]); console.log("compiled") } catch { console.log("refused at compile time") }' "$PATTERN")"
printf '%-12s %s\n' java "$(java "$tmp/P.java" "$PATTERN")"
printf '%-12s %s\n' "go regexp" "$(cd "$tmp" && go run probe.go "$PATTERN")"
