REPORT z_nested_parens.

" Nested structures in ABAP, in the PCRE syntax available as of release 7.55.
" The PCRE addition hands the pattern to the PCRE2 library in the kernel, so
" ABAP gets Perl's recursion: (?R), (?1) and (?&name). Python, Java, JavaScript,
" Go and Rust have none of these, which makes this one of the few places where
" an ABAP one-liner does something those languages need a loop for.
"
" Nothing in this repository can run ABAP, so this file is checked by abaplint
" and printed as source only -- there is no recorded output beside it. What the
" engine underneath does is on the lesson page, as a dated pcre2grep run.

DATA candidates TYPE STANDARD TABLE OF string WITH EMPTY KEY.
DATA verdict TYPE string.

DATA(text) = `f( a, g( b, h( c ) ), d ) + k( e )`.

" (?1) re-runs group 1's PATTERN at this position -- not the text group 1
" captured, which is what \1 would mean. That is the whole trick: the group's
" definition mentions the group, so it can nest to any depth.
DATA(outermost) = `(\((?:[^()]|(?1))*\))`.

FIND ALL OCCURRENCES OF PCRE outermost IN text RESULTS DATA(matches).

LOOP AT matches INTO DATA(match).
  WRITE / |{ match-offset } { substring( val = text
                                         off = match-offset
                                         len = match-length ) }|.
ENDLOOP.

" Anchoring needs the (?1) form, not (?R). ^...(?R)...$ compiles and then
" matches only subjects that never enter the recursion, because the recursive
" call re-runs the anchors too.
DATA(whole_string) = `^(\((?:[^()]|(?1))*\))$`.

APPEND `(a(b)c)` TO candidates.
APPEND `(a(b)c` TO candidates.
APPEND `a)b` TO candidates.

LOOP AT candidates INTO DATA(candidate).
  FIND FIRST OCCURRENCE OF PCRE whole_string IN candidate.
  IF sy-subrc = 0.
    verdict = `balanced`.
  ELSE.
    verdict = `not one balanced group`.
  ENDIF.
  WRITE / |{ candidate } { verdict }|.
ENDLOOP.

" Worth saying out loud: a recursive pattern is still a backtracking search, so
" hostile input costs what backtracking costs. When the structure is a real
" grammar -- nested IF blocks, XML, a formula language -- count the depth in
" ABAP instead, or parse it. The regex is shorter, not safer.
