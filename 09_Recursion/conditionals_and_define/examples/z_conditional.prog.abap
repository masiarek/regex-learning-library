REPORT z_conditional.

" ABAP's PCRE addition is the PCRE2 library in the kernel, so ABAP has the
" whole conditional family: (?(1)yes|no), (?(<name>)yes|no), a lookaround as
" the condition, and the (?(DEFINE)...) block.
" Source only -- nothing in this repository can run ABAP. Checked by abaplint.

TYPES ty_subjects TYPE STANDARD TABLE OF string WITH EMPTY KEY.

" An optional opening delimiter that makes the closing one mandatory:
" <tag> and tag match, <tag does not.
"
" Named, not numbered. (?(1)...) would be correct today and wrong the moment
" somebody adds a capture group in front of it, and nothing would report it.
DATA(pattern) = `^(?<open><)?\w+(?(<open>)>)$`.

DATA(subjects) = VALUE ty_subjects( ( `<tag>` ) ( `tag` ) ( `<tag` ) ).

LOOP AT subjects INTO DATA(subject).
  FIND FIRST OCCURRENCE OF PCRE pattern IN subject.
  IF sy-subrc = 0.
    WRITE / |{ subject } matches|.
  ELSE.
    WRITE / |{ subject } does not match|.
  ENDIF.
ENDLOOP.

" (?(DEFINE)...) declares named parts and matches nothing itself, so the
" pattern proper can be assembled out of them. With (?x) -- extended, or
" free-spacing, mode -- whitespace inside the pattern is ignored and the
" definition fits on a line a reviewer can check.
DATA(ipv4) =
  `(?x)`                                                 &&
  `(?(DEFINE)`                                           &&
  `  (?<octet>  25[0-5] | 2[0-4]\d | 1\d\d | [1-9]?\d )`  &&
  `)`                                                    &&
  `^ (?&octet) \. (?&octet) \. (?&octet) \. (?&octet) $`.

DATA(host) = `192.168.0.1`.
FIND FIRST OCCURRENCE OF PCRE ipv4 IN host.
IF sy-subrc = 0.
  WRITE / |{ host } is a dotted quad|.
ENDIF.

" A condition naming a group the pattern does not have is a compile error in
" PCRE2 -- CX_SY_INVALID_REGEX at runtime here, not a silent false branch the
" way Perl takes it. And (?(R)...) is PCRE2's recursion test, so a group you
" name R has to be asked for as (?(<R>)...).
