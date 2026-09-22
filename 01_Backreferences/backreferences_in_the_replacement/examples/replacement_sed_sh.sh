#!/usr/bin/env bash
# sed is the reason so many people read \1 as a replacement instruction first.
set -u
echo "DE44 5001 0517" | sed 's/\([0-9]\{4\}\) \([0-9]\{4\}\)/\1-\2/'

# & is the whole match, as $& is in Perl and JavaScript.
echo "order 42" | sed 's/[0-9][0-9]*/[&]/'

# In the PATTERN, \1 is a real backreference -- the same doubled-word test.
# (\w is a GNU extension; [a-z][a-z]* is what both seds agree on.)
printf 'the the cat\nthe cat\n' | sed -n 's/\([a-z][a-z]*\) \1/DOUBLED: &/p'
