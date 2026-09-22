#!/usr/bin/env bash
# The POSIX command line, where leftmost-longest is the law and nobody mentions
# it. Three tools, three separate regex engines -- BSD libc here, GNU grep, GNU
# sed and mawk on the CI runner -- and one answer.
#
# grep and sed are called by absolute path on purpose: `grep` on the author's
# PATH is ugrep, which is a different program with a different engine. Only
# flags POSIX defines (-E, -o for grep; -E for sed) are used, because BSD and
# GNU part company outside them.
set -u

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
printf 'ab\n' > "$tmp/ab.txt"
printf 'v 3.14 w\n' > "$tmp/pi.txt"

row() { printf '%-39s %-10s %s\n' "$1" "$2" "$3"; }

row "tool and pattern" "subject" "result"
row "grep -E -o 'a|ab'" "ab" \
    "$(/usr/bin/grep -E -o 'a|ab' "$tmp/ab.txt")"
row "grep -E -o '[0-9]+|[0-9]+\.[0-9]+'" "v 3.14 w" \
    "$(/usr/bin/grep -E -o '[0-9]+|[0-9]+\.[0-9]+' "$tmp/pi.txt")"
row "sed -E 's/a|ab/[&]/'" "ab" \
    "$(/usr/bin/sed -E 's/a|ab/[&]/' "$tmp/ab.txt")"
row "sed -E 's/[0-9]+|[0-9]+\.[0-9]+/[&]/'" "v 3.14 w" \
    "$(/usr/bin/sed -E 's/[0-9]+|[0-9]+\.[0-9]+/[&]/' "$tmp/pi.txt")"
row "awk match(\$0, /a|ab/)" "ab" \
    "$(/usr/bin/awk '{ if (match($0, /a|ab/)) printf "%s at %d len %d", substr($0, RSTART, RLENGTH), RSTART, RLENGTH }' "$tmp/ab.txt")"
row "awk match(\$0, /[0-9]+|[0-9]+\.[0-9]+/)" "v 3.14 w" \
    "$(/usr/bin/awk '{ if (match($0, /[0-9]+|[0-9]+\.[0-9]+/)) printf "%s at %d len %d", substr($0, RSTART, RLENGTH), RSTART, RLENGTH }' "$tmp/pi.txt")"
