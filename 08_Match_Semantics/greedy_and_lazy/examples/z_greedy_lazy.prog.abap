REPORT z_greedy_lazy.

" Greedy and lazy in ABAP, in the PCRE syntax available as of release 7.55.
" Nothing in this repository can run ABAP, so this file is checked by abaplint
" and printed here as source only -- there is no recorded output beside it.
" What the PCRE2 library underneath does with these patterns is on the page,
" as a dated pcre2grep run.

DATA(text) = `<b>bold</b>`.

" Greedy: .+ takes everything it can and gives back only what it must, so the
" match runs to the LAST > on the line.
FIND FIRST OCCURRENCE OF PCRE `<.+>` IN text
     MATCH OFFSET DATA(greedy_off) MATCH LENGTH DATA(greedy_len).

" Lazy: .+? takes one character and asks for more only when > does not fit yet,
" so the match stops at the FIRST >.
FIND FIRST OCCURRENCE OF PCRE `<.+?>` IN text
     MATCH OFFSET DATA(lazy_off) MATCH LENGTH DATA(lazy_len).

" And the spelling that needs neither: a class that cannot cross a >. It is the
" one to reach for when a pattern is slow, because ? is not a speed control.
FIND FIRST OCCURRENCE OF PCRE `<[^>]+>` IN text
     MATCH OFFSET DATA(class_off) MATCH LENGTH DATA(class_len).

WRITE / |greedy { substring( val = text off = greedy_off len = greedy_len ) }|.
WRITE / |lazy   { substring( val = text off = lazy_off   len = lazy_len ) }|.
WRITE / |class  { substring( val = text off = class_off  len = class_len ) }|.

" Stripping the tags shows the same difference as a replacement: the greedy
" pattern deletes the text between them as well.
DATA(greedy_stripped) = text.
DATA(lazy_stripped) = text.
REPLACE ALL OCCURRENCES OF PCRE `<.+>`   IN greedy_stripped WITH ``.
REPLACE ALL OCCURRENCES OF PCRE `<.+?>`  IN lazy_stripped   WITH ``.
WRITE / |greedy stripped "{ greedy_stripped }"|.
WRITE / |lazy stripped   "{ lazy_stripped }"|.
