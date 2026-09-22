REPORT z_case_insensitive.

" Case-insensitive matching in ABAP, whose PCRE addition (7.55 and later) is the
" PCRE2 library in the kernel. Nothing in this repository can run ABAP, so this
" file is parsed by abaplint and shown on the page as source only -- there is no
" recorded output beside it, and none of the comments below is a measured claim
" about a real system.

DATA(text) = `Kelvin`.

" Two ways to ask for caseless matching, and they are not the same question.

" 1. IGNORING CASE is ABAP's own addition. It governs the WHOLE statement: there
"    is no way to spell "this part caselessly, that part exactly".
FIND FIRST OCCURRENCE OF PCRE `kelvin` IN text IGNORING CASE.
ASSERT sy-subrc = 0.

" 2. (?i) is PCRE2's, so it can be scoped. (?i:...) makes one group caseless and
"    leaves the rest of the pattern case-sensitive -- and a pattern that arrives
"    from configuration carries its own flags with it, which IGNORING CASE in the
"    calling code cannot take back.
FIND FIRST OCCURRENCE OF PCRE `(?i:kel)vin` IN text.
ASSERT sy-subrc = 0.

" Neither addition settles WHICH characters count as the same letter. That is
" the kernel's PCRE2 case-folding table, and it is the table -- not ABAP -- that
" decides whether the two patterns below find anything:
"
"   \x{212A}  KELVIN SIGN, which folds to a plain k in PCRE2's UTF mode
"   ss        which does NOT match U+00DF: PCRE2 does simple folding, not full
"
" A pattern may be written entirely in ASCII, because PCRE2's \x{...} escape
" names a code point -- worth doing in ABAP, where a literal in a transport is
" at the mercy of every editor it passes through.
FIND FIRST OCCURRENCE OF PCRE `(?i)\x{212A}` IN text.
IF sy-subrc = 0.
  WRITE / `the kernel folds U+212A onto k`.
ELSE.
  WRITE / `the kernel does not`.
ENDIF.

" (*CASELESS_RESTRICT) -- keep ASCII and non-ASCII apart while still folding --
" needs PCRE2 10.43 or later in the kernel, so whether it compiles is a question
" about your system, not about ABAP. Check before relying on it.
