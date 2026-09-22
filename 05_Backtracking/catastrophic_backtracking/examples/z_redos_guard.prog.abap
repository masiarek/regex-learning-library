REPORT z_redos_guard.

" ABAP's PCRE addition (7.55 and later) is the PCRE2 library in the kernel, so
" this page's question -- what happens to a nested quantifier on a subject built
" to fail -- is really a question about PCRE2. Nothing in this repository can
" run ABAP, so this file is checked by abaplint and printed as source only;
" there is no recorded output beside it. What PCRE2 itself does is on the page,
" as a dated pcre2grep run.

" 120 a's and then one character that cannot match. The a's can be split
" between the inner + and the outer + in 2**119 ways, and a backtracking engine
" has to refuse every one of them before it can say "no".
DATA(hostile) = repeat( val = `a` occ = 120 ) && `!`.

" PCRE2 counts the steps a match takes and stops at a built-in match limit
" rather than running until the work process is killed. ABAP surfaces that as a
" catchable exception, so the shape to write is a TRY, not a longer timeout.
TRY.
    FIND FIRST OCCURRENCE OF PCRE `^(a+)+$` IN hostile.
    WRITE / |nested quantifier: sy-subrc = { sy-subrc }|.
  CATCH cx_sy_regex_too_complex.
    WRITE / |nested quantifier: the engine gave up|.
ENDTRY.

" The same question, with the inner repetition made possessive. `a++` matches
" the whole run of a's and never gives any of it back, so there is only one way
" to split the subject and nothing to search. No limit to hit, no exception to
" catch, and the answer is the same one.
FIND FIRST OCCURRENCE OF PCRE `^(a++)+$` IN hostile.
WRITE / |possessive:         sy-subrc = { sy-subrc }|.

" An atomic group says the same thing about a sub-expression rather than about
" one quantifier, and PCRE2 has had both for as long as ABAP has had PCRE.
FIND FIRST OCCURRENCE OF PCRE `^(?>a+)+$` IN hostile.
WRITE / |atomic group:       sy-subrc = { sy-subrc }|.

" Better than either: stop nesting. This pattern asks the same question of the
" same subject and gives a backtracker nothing to choose between.
FIND FIRST OCCURRENCE OF PCRE `^a+$` IN hostile.
WRITE / |not nested at all:  sy-subrc = { sy-subrc }|.
