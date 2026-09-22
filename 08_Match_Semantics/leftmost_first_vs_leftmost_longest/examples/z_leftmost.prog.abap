REPORT z_leftmost.

" Which rule an ABAP statement is on depends on one word in it, and the word is
" not part of the pattern.
"
" Nothing in this repository can run ABAP, so this file is checked by abaplint
" and printed here as source only -- there is no recorded output beside it.

DATA(text) = `v 3.14 w`.

" The PCRE addition (7.55 and later) is the PCRE2 library in the kernel, and
" PCRE2 is Perl's engine: leftmost-FIRST. The first alternative that works at
" the earliest position wins and the search stops there, so [0-9]+ succeeds on
" the 3 and the decimal point is never reached. Offset 2, length 1.
FIND PCRE `[0-9]+|[0-9]+\.[0-9]+` IN text
     MATCH OFFSET DATA(first_offset) MATCH LENGTH DATA(first_length).
WRITE / |{ first_offset } { first_length } { substring( val = text
                                                        off = first_offset
                                                        len = first_length ) }|.

" Put the longer alternative first and the same engine, the same subject and
" the same set of alternatives give offset 2, length 4. In a leftmost-first
" engine the ORDER of the alternatives is part of the meaning of the pattern.
FIND PCRE `[0-9]+\.[0-9]+|[0-9]+` IN text
     MATCH OFFSET DATA(long_offset) MATCH LENGTH DATA(long_length).
WRITE / |{ long_offset } { long_length } { substring( val = text
                                                      off = long_offset
                                                      len = long_length ) }|.

" The migration hazard worth a test: the obsolete REGEX addition, which PCRE
" replaced in 7.55, was a POSIX-flavoured engine, and a POSIX engine is
" leftmost-LONGEST. Swapping REGEX for PCRE can therefore change which text a
" working report matches while leaving the pattern character-for-character the
" same -- exactly the kind of change a diff review waves through. abaplint
" rejects the REGEX addition as obsolete, which is why this file cannot show
" you the old spelling next to the new one.
