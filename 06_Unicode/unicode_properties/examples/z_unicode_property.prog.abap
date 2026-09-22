REPORT z_unicode_property.

" Unicode properties in ABAP, through the PCRE addition available as of 7.55.
" Nothing in this repository can run ABAP, so this file is checked by abaplint
" and printed here as source only -- there is no recorded output beside it.
"
" ABAP does not have a regex engine of its own: the PCRE addition hands the
" pattern to the PCRE2 library in the kernel. So the answers are PCRE2's, and
" a `pcre2grep` on any machine predicts them. The page beside this file records
" one such run.

DATA(amount) = `1234`.
DATA(name)   = `Andreas`.

" A numeric field. \p{Nd} is every DECIMAL DIGIT in every script, so this
" accepts U+0660 ARABIC-INDIC DIGIT ZERO as readily as U+0037 DIGIT SEVEN --
" which is very probably not what a posting amount should accept. [0-9] is
" the honest pattern for a field that a numeric conversion has to survive.
IF matches( val = amount pcre = `\A[0-9]+\z` ).
  WRITE / `amount is ASCII digits only`.
ENDIF.

IF matches( val = amount pcre = `\A\p{Nd}+\z` ).
  WRITE / `amount is decimal digits in some script -- not the same test`.
ENDIF.

" A name field. \p{L} is every letter in every script; [A-Za-z] is a rule that
" rejects half of the customer master.
IF matches( val = name pcre = `\A[\p{L}\p{Zs}'-]+\z` ).
  WRITE / `name is letters, spaces, apostrophe and hyphen`.
ENDIF.

" Scripts. PCRE2 takes the bare name and the Script= form. It does NOT take
" Perl's Is prefix: `\p{IsGreek}` is "unknown property after \P or \p" in
" PCRE2 10.48, which is the single spelling most likely to arrive in a pattern
" copied out of a Perl program.
FIND ALL OCCURRENCES OF PCRE `\p{Greek}+` IN name RESULTS DATA(greek).
FIND ALL OCCURRENCES OF PCRE `\p{Script=Han}+` IN name RESULTS DATA(han).

" \X is one grapheme cluster: what a user calls one character, however many
" code points it takes. A truncation to a fixed length that counts with . or
" with strlen can cut a combining mark away from its base letter; counting
" with \X cannot.
FIND ALL OCCURRENCES OF PCRE `\X` IN name RESULTS DATA(graphemes).

WRITE / |{ lines( greek ) } greek runs, { lines( han ) } han runs, { lines( graphemes ) } graphemes|.

" CL_ABAP_REGEX=>CREATE_PCRE( ) and CL_ABAP_MATCHER are the object-oriented
" way in, and they take the same property syntax, because it is the same
" library underneath.
