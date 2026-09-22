REPORT z_lookaround.

" ABAP's PCRE addition is the PCRE2 library, so lookaround is the Perl one:
" lookahead of any width, lookbehind of a known width, and alternatives of
" different fixed lengths allowed. Source only -- nothing here can run ABAP.

DATA(text) = `250 EUR and 90 USD`.

" Lookahead: the amount that is followed by EUR, without capturing EUR.
FIND ALL OCCURRENCES OF PCRE `\d+(?= EUR)` IN text RESULTS DATA(amounts).

" Lookbehind: the amount that follows a currency code. Each branch is a fixed
" width, which PCRE2 allows even though the two branches differ.
DATA(prices) = `EUR 250 USD 90`.
FIND ALL OCCURRENCES OF PCRE `(?<=EUR |USD )\d+` IN prices RESULTS DATA(found).

" \K is PCRE's other way of saying the same thing: everything before it is
" matched and then dropped from the reported match.
FIND FIRST OCCURRENCE OF PCRE `EUR \K\d+` IN prices RESULTS DATA(kept).
