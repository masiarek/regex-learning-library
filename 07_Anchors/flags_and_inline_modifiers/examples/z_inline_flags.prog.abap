REPORT z_inline_flags.

" ABAP's PCRE addition is the PCRE2 library, so every inline modifier on this
" page is available inside the pattern: (?i), (?s), (?m), (?x), and the scoped
" forms (?i:...) and (?-i:...). What ABAP adds on top is IGNORING CASE, a
" statement addition that lives outside the pattern.
"
" Source only -- nothing in this repository can run ABAP.

DATA(text) = `Invoice INV-42 and invoice inv-43`.

" 1. The statement addition. It applies to the whole pattern, and it is invisible
"    the moment the pattern travels: into a customising table, a message, a log
"    line, or a colleague's Python script.
FIND ALL OCCURRENCES OF PCRE `inv-\d+` IN text IGNORING CASE RESULTS DATA(loose).

" 2. The inline modifier. The same answer, but the pattern carries its own
"    meaning wherever it is pasted.
FIND ALL OCCURRENCES OF PCRE `(?i)inv-\d+` IN text RESULTS DATA(carried).

" 3. Scoped to a sub-pattern: the three letters are case-insensitive and nothing
"    else is. IGNORING CASE cannot express this at all.
FIND ALL OCCURRENCES OF PCRE `(?i:inv)-\d+` IN text RESULTS DATA(scoped).

" 4. Free-spacing. A pattern kept in a Z table is read far more often than it is
"    written, and (?x) is the only way to comment one in place.
FIND FIRST OCCURRENCE OF PCRE `(?x) INV - (\d+)   # the document number`
  IN text RESULTS DATA(readable).

" 5. Multi-line, the ABAP way. IN TABLE runs the pattern against each row, so ^
"    and $ anchor per row with no flag involved -- this is what most ABAP code
"    means by "multiline", and it is not the (?m) question at all.
DATA rows TYPE STANDARD TABLE OF string WITH EMPTY KEY.
rows = VALUE #( ( `one` ) ( `two` ) ( `three` ) ).
FIND ALL OCCURRENCES OF PCRE `^two$` IN TABLE rows RESULTS DATA(per_row).

" 6. Multi-line, the one-string way. A string that really holds newlines needs
"    (?m) before ^ and $ become line anchors, exactly as in Perl.
DATA(multi) = |one{ cl_abap_char_utilities=>newline }two|.
FIND FIRST OCCURRENCE OF PCRE `(?m)^two$` IN multi RESULTS DATA(per_line).

" The obsolete REGEX addition took the same IGNORING CASE but a different
" engine, and it does not agree with PCRE2 at the edges. New code uses PCRE.
