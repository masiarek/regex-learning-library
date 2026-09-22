REPORT z_unicode_classes.

" ABAP's PCRE addition (7.55 and later) is the PCRE2 library, and PCRE2's \w is
" ASCII-only until the UCP option is switched on. (*UCP) at the very start of a
" pattern is the portable way to ask for it, and it is the same switch this
" lesson measures with pcre2grep.
"
" Nothing in this repository can run ABAP, so this file is checked by abaplint
" and printed as source only -- there is no recorded output beside it.
"
" The source has to stay 7-bit ASCII (abaplint enforces that), so the one
" non-ASCII character in the subject is built from its code point rather than
" typed: on a Unicode ABAP system a character field holds UTF-16 code units, so
" casting a two-byte hex field to a character field yields U+00EF directly.

DATA hex TYPE x LENGTH 2 VALUE '00EF'.   " U+00EF LATIN SMALL LETTER I WITH DIAERESIS
FIELD-SYMBOLS <char> TYPE c.

ASSIGN hex TO <char> CASTING TYPE c.

" "naive reader", with U+00EF in the middle of the first word.
DATA(text) = |na{ <char> }ve reader|.

" \w without UCP is [A-Za-z0-9_], so \b\w+\b finds three "words" here --
" na, ve and reader -- and the first name in your customer table is silently
" cut in half.
FIND ALL OCCURRENCES OF PCRE `\b\w+\b`
     IN text RESULTS DATA(ascii_words).

" With UCP, \w is the Unicode word property, so the same pattern finds two.
FIND ALL OCCURRENCES OF PCRE `(*UCP)\b\w+\b`
     IN text RESULTS DATA(unicode_words).

DATA(ascii_count)   = lines( ascii_words ).
DATA(unicode_count) = lines( unicode_words ).

WRITE / |words found without UCP: { ascii_count }|.
WRITE / |words found with (*UCP): { unicode_count }|.

" \d is the same question with sharper consequences: (*UCP) applies to \d as
" well, so (*UCP)\d+ also accepts U+0660..U+0669 ARABIC-INDIC DIGIT ZERO..NINE
" -- measured here with pcre2grep, not on an ABAP system. A pattern that wants
" Unicode letters and ASCII digits therefore has to spell the digits out as
" [0-9]; if the pattern is a validation, that is the safe default.
