REPORT z_doubled_word.

" Backreferences in ABAP, in the PCRE syntax available as of release 7.55.
" Nothing in this repository can run ABAP, so this file is checked by abaplint
" and printed here as source only -- there is no recorded output beside it.

DATA(text) = `the the quick brown fox fox jumped`.

" \1 is the text group 1 captured, exactly as in Perl: the PCRE addition hands
" the pattern to the PCRE2 library built into the ABAP kernel.
FIND ALL OCCURRENCES OF PCRE `\b(\w+) \1\b`
     IN text RESULTS DATA(matches).

LOOP AT matches INTO DATA(match).
  WRITE / |{ match-offset } { substring( val = text
                                         off = match-offset
                                         len = match-length ) }|.
ENDLOOP.

" The older REGEX addition understands \1 too, but it is obsolete as of 7.55 --
" and abaplint enforces that, which is why there is no REGEX statement here.
