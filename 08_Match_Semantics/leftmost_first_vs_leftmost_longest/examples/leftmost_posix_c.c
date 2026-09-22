/* POSIX <regex.h> with REG_EXTENDED -- a genuine leftmost-longest engine, and
 * the one every Perl-family engine on this page disagrees with.
 *
 * Only questions whose answer is the same on macOS (the BSD/Spencer regex in
 * libc) and on Linux (glibc) are printed here, because this output is an
 * answer key checked on both. Where the two libcs part company -- the
 * assignment of text to SUBEXPRESSIONS -- the page shows two dated real runs
 * instead, which is the honest way to record a disagreement.
 */
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>

/* Print the first match of `pattern` in `subject`, with its half-open offsets. */
static void whole_match(const char *pattern, const char *subject)
{
    regex_t re;
    regmatch_t m;

    if (regcomp(&re, pattern, REG_EXTENDED) != 0) {
        printf("%-22s %-9s regcomp refused it\n", pattern, subject);
        exit(1);
    }
    if (regexec(&re, subject, 1, &m, 0) != 0) {
        printf("%-22s %-9s no match\n", pattern, subject);
    } else {
        printf("%-22s %-9s %-9.*s [%d,%d)\n", pattern, subject,
               (int)(m.rm_eo - m.rm_so), subject + m.rm_so,
               (int)m.rm_so, (int)m.rm_eo);
    }
    regfree(&re);
}

/* Print the whole match and the first two groups. */
static void with_groups(const char *pattern, const char *subject)
{
    regex_t re;
    regmatch_t m[3];
    size_t i;

    if (regcomp(&re, pattern, REG_EXTENDED) != 0 ||
        regexec(&re, subject, 3, m, 0) != 0) {
        printf("%-22s %-9s no match\n", pattern, subject);
        exit(1);
    }
    printf("%-22s %-9s whole=%.*s", pattern, subject,
           (int)(m[0].rm_eo - m[0].rm_so), subject + m[0].rm_so);
    for (i = 1; i < 3; i++) {
        printf(" g%d=%.*s", (int)i,
               (int)(m[i].rm_eo - m[i].rm_so), subject + m[i].rm_so);
    }
    printf("\n");
    regfree(&re);
}

int main(void)
{
    printf("%-22s %-9s %-9s %s\n", "pattern", "subject", "match", "offsets");

    /* The alternation whose order every Perl-family engine obeys and this one
     * ignores: a is tried first, ab wins anyway because it is longer. */
    whole_match("a|ab", "ab");
    whole_match("ab|a", "ab");

    /* Leftmost first, THEN longest: the match starts at offset 2 either way,
     * and among the matches starting there the longest one is taken. */
    whole_match("[0-9]+|[0-9]+\\.[0-9]+", "v 3.14 w");
    whole_match("[0-9]+\\.[0-9]+|[0-9]+", "v 3.14 w");

    /* POSIX also asks each subexpression to be as long as it can be given the
     * whole match, left to right -- so group 1 takes all three a's and group 2
     * is left with nothing. Both libcs agree on this one. */
    printf("\n");
    with_groups("(a*)(a*)", "aaa");
    return 0;
}
