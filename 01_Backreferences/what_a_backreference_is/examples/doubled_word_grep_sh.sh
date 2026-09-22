#!/usr/bin/env bash
# The oldest spelling of a backreference, and the one POSIX actually requires.
set -u
printf 'the the cat\nthe cat\nfox fox\n' > /tmp/regex_lib_words.txt

# Basic regular expressions: groups are \( \) and the backreference is \1.
# POSIX requires backreferences in BRE...
echo "BRE  (grep):"
/usr/bin/grep '\(\w\+\) \1' /tmp/regex_lib_words.txt

# ...and does NOT require them in ERE. Both GNU and BSD grep support them
# anyway, which is why a script that relies on it is portable in practice and
# unportable on paper.
echo "ERE  (grep -E):"
/usr/bin/grep -E '(\w+) \1' /tmp/regex_lib_words.txt

rm -f /tmp/regex_lib_words.txt
