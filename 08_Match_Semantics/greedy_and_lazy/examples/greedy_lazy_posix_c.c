/* POSIX <regex.h>, REG_EXTENDED: the engine with no lazy quantifier.
 *
 * POSIX ERE has `*`, `+`, `?` and `{m,n}` and nothing else. There is no `*?`.
 * A `?` written after a repetition is therefore not "lazy" -- it is a second
 * repetition operator applied to the first one, which is a different pattern.
 *
 * The two libcs this example must satisfy disagree about what to DO with that,
 * and the disagreement is the lesson, so it cannot also be the answer key: the
 * default output prints only what is true on both (macOS's BSD/Spencer regex
 * and glibc). Run the program with the single argument `raw` to see this
 * machine's unfiltered answer -- the page records one such run per platform,
 * dated, which is the honest way to publish a disagreement.
 */
#include <regex.h>
#include <stdio.h>
#include <string.h>

/* Match `pattern` against `subject`; copy the matched text into `out`.
 * Returns 1 on a match, 0 on no match, -1 if the pattern would not compile. */
static int first_match(const char *pattern, const char *subject, char *out, size_t cap)
{
    regex_t re;
    regmatch_t m;
    size_t len;

    out[0] = '\0';
    if (regcomp(&re, pattern, REG_EXTENDED) != 0)
        return -1;
    if (regexec(&re, subject, 1, &m, 0) != 0) {
        regfree(&re);
        return 0;
    }
    len = (size_t)(m.rm_eo - m.rm_so);
    if (len >= cap)
        len = cap - 1;
    memcpy(out, subject + m.rm_so, len);
    out[len] = '\0';
    regfree(&re);
    return 1;
}

/* A question POSIX answers the same way in every libc. */
static void portable(const char *pattern, const char *subject)
{
    char text[64];
    int rc = first_match(pattern, subject, text, sizeof text);

    if (rc == 1)
        printf("  %-9s -> \"%s\"\n", pattern, text);
    else
        printf("  %-9s -> %s\n", pattern, rc == 0 ? "no match" : "did not compile");
}

/* A spelling borrowed from a lazy engine. `lazy` is the answer Perl, Python,
 * JavaScript, Java, Ruby, Go and Rust all give for it. */
static void lazy_question(const char *pattern, const char *subject, const char *lazy)
{
    char text[64];
    char want[64];
    int rc = first_match(pattern, subject, text, sizeof text);
    int same = (rc == 1 && strcmp(text, lazy) == 0);

    snprintf(want, sizeof want, "\"%s\"", lazy);
    printf("  %-9s a lazy engine gives %-7s POSIX ERE: %s\n",
           pattern, want, same ? "the same" : "not the lazy answer");
}

/* What this libc really did -- compile error or match. Not an answer key. */
static void raw(const char *pattern, const char *subject)
{
    regex_t re;
    regmatch_t m;
    char err[128];
    int rc = regcomp(&re, pattern, REG_EXTENDED);

    if (rc != 0) {
        regerror(rc, &re, err, sizeof err);
        printf("  %-9s on \"%s\": regcomp refused it: %s\n", pattern, subject, err);
        return;
    }
    if (regexec(&re, subject, 1, &m, 0) != 0)
        printf("  %-9s on \"%s\": no match\n", pattern, subject);
    else
        printf("  %-9s on \"%s\": matched \"%.*s\" at [%d,%d)\n", pattern, subject,
               (int)(m.rm_eo - m.rm_so), subject + m.rm_so,
               (int)m.rm_so, (int)m.rm_eo);
    regfree(&re);
}

int main(int argc, char **argv)
{
    const char *tag = "<b>bold</b>";
    const char *aaa = "aaa";

    if (argc > 1 && strcmp(argv[1], "raw") == 0) {
        printf("raw: what this libc does with the lazy spellings\n");
        raw("<.+?>", tag);
        raw("a+?", aaa);
        raw("a+?", "b");
        raw("a*?", aaa);
        raw("a{1,3}?", aaa);
        return 0;
    }

    printf("POSIX ERE, subject \"%s\"\n", tag);
    portable("<.+>", tag);
    portable("<[^>]+>", tag);
    portable("<(.+)?>", tag);
    printf("POSIX ERE, subject \"%s\"\n", aaa);
    portable("a+", aaa);
    portable("(a+)?", aaa);
    portable("a?", aaa);

    printf("the lazy spellings, which POSIX ERE does not define\n");
    lazy_question("<.+?>", tag, "<b>");
    lazy_question("a+?", aaa, "a");
    lazy_question("a*?", aaa, "");
    lazy_question("a{1,3}?", aaa, "a");
    return 0;
}
