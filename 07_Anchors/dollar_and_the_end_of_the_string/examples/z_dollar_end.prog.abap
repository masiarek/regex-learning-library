REPORT z_dollar_end.

" The anchors in ABAP are PCRE2's, because the PCRE addition (7.55 and later)
" is the PCRE2 library in the kernel: `$` is the end of the string OR the
" position just before a newline at the end of it, `\Z` is the same, and `\z`
" is the end of the string and nothing else.
"
" Nothing in this repository can run ABAP, so this file is source only --
" abaplint parses it and no answer key is recorded beside it. What WAS run is
" the engine underneath; see the dated pcre2grep transcript on the lesson page.

" The value a validator is handed after a flat file, an IDoc segment or a form
" field has kept its line break.
DATA(input) = |1{ cl_abap_char_utilities=>newline }|.

" A SEARCH. FIND asks whether a position exists somewhere in the value, not
" whether the whole value is digits, and `$` will step over that trailing
" newline to find one.
FIND FIRST OCCURRENCE OF PCRE `^\d+$` IN input.
DATA(loose) = COND string( WHEN sy-subrc = 0 THEN `found` ELSE `not found` ).

" The same search with the ends of the STRING asked for by name. Of the three
" spellings, `\z` is the only one that cannot step over anything.
FIND FIRST OCCURRENCE OF PCRE `\A\d+\z` IN input.
DATA(strict) = COND string( WHEN sy-subrc = 0 THEN `found` ELSE `not found` ).

" And the built-in that asks the whole-value question directly. matches( )
" requires the pattern to account for every character of val, the way Java's
" String.matches and Python's re.fullmatch do, so it needs no anchors at all --
" and it is the form to reach for in new ABAP.
DATA(whole) = COND string( WHEN matches( val = input pcre = `\d+` ) = abap_true
                           THEN `accepted`
                           ELSE `rejected` ).

WRITE / |{ loose } / { strict } / { whole }|.
