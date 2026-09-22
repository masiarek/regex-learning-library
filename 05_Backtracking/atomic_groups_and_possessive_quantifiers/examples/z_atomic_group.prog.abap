REPORT z_atomic_group.

" ABAP's PCRE addition is the PCRE2 library, so both spellings are here: the
" atomic group (?>...) and the possessive quantifiers ++ *+ ?+. Source only --
" nothing in this repository can run ABAP, so there is no output beside it.

DATA(host) = `example.com`.

" This one matches. [\w.]+ first swallows the whole string, then hands back the
" four characters of '.com' so the literal that follows can have them.
FIND FIRST OCCURRENCE OF PCRE `^[\w.]+\.com$` IN host RESULTS DATA(plain).

" This one matches nothing, on any input at all. [\w.] includes the dot, so the
" possessive quantifier swallows '.com' too and then refuses to give a single
" character back. The pattern compiles, the FIND simply sets sy-subrc = 4, and
" a test that only asks "did it dump?" will not notice.
FIND FIRST OCCURRENCE OF PCRE `^[\w.]++\.com$` IN host RESULTS DATA(swallowed).

" Where it pays: \d can never match the separator, so forbidding the
" backtracking costs nothing -- and a long run of digits stops being a place
" where a FAILING match has to try every split of the run.
DATA(amount) = `1234567890.55`.
FIND FIRST OCCURRENCE OF PCRE `^\d++\.\d++$` IN amount RESULTS DATA(number).

" The atomic group is the same instruction with a wider scope: everything
" inside it is matched once and never reconsidered.
FIND FIRST OCCURRENCE OF PCRE `^(?>\d+)\.\d+$` IN amount RESULTS DATA(atomic).
