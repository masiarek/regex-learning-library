REPORT z_replacement.

" In ABAP the replacement pattern uses $1, like JavaScript and Perl -- not \1.
" Source only: nothing here can run ABAP. Checked by abaplint.

DATA(iban) = `DE44 5001 0517 5407 3249 31`.

REPLACE ALL OCCURRENCES OF PCRE `(\d{4}) (\d{4})`
        IN iban WITH `$1-$2`.

" $0 is the whole match, and ${1} is the form that survives a following digit.
DATA(order) = `order 42`.
REPLACE ALL OCCURRENCES OF PCRE `\d+` IN order WITH `[$0]`.

" When the replacement text is DATA rather than a pattern, the addition
" VERBATIM turns off the special meaning of $ instead of hoping the data has
" none. It is shown on the lesson page rather than here: abaplint 2.120.19
" does not parse it yet, and this file is kept lint-clean.
