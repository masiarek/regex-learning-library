// The same patterns and the same hostile subjects, handed to an automaton.
//
// Nothing here is capped, because there is nothing to cap: RE2 makes one pass
// over the subject whatever the pattern's nesting looks like, so the interesting
// number is how big the subject can get -- a megabyte, here -- rather than how
// long the match took.
package main

import (
	"fmt"
	"regexp"
	"strings"
)

const email = `^([a-zA-Z0-9_\.\-])+@(([a-zA-Z0-9\-])+\.)+([a-zA-Z]{2,4})+$`

func answer(pattern, subject string) string {
	if regexp.MustCompile(pattern).MatchString(subject) {
		return "match"
	}
	return "no match"
}

func main() {
	hostile := strings.Repeat("a", 120) + "!"
	megabyte := strings.Repeat("a", 1000000) + "!"
	blanks := strings.Repeat(" ", 1000000) + "!"

	fmt.Println("patterns with no backreference, go regexp:")
	rows := []struct {
		pattern, shown, subject, described string
	}{
		{`^(a+)+$`, "", hostile, "120 a's then '!'"},
		{`^(a+)+$`, "", megabyte, "1000000 a's then '!'"},
		{`^(a|a)*$`, "", megabyte, "1000000 a's then '!'"},
		{`^(\s*|\t)+$`, "", blanks, "1000000 spaces, '!'"},
		{`^(\w+\s?)*$`, "", megabyte, "1000000 a's then '!'"},
		{`^([a-z]{2,4})+$`, "", megabyte, "1000000 a's then '!'"},
		{email, "the email regex", "a@a." + megabyte, "a@a. then a megabyte"},
	}
	for _, row := range rows {
		shown := row.shown
		if shown == "" {
			shown = row.pattern
		}
		fmt.Printf("  %-24s %-22s %s\n", shown, row.described, answer(row.pattern, row.subject))
	}

	// And the other half of the trade: the two constructs every backtracking
	// engine on this page uses to cut the search are not merely unnecessary
	// here, they are rejected.
	fmt.Println()
	fmt.Println("the fixes the other engines need, handed to RE2:")
	for _, pattern := range []string{`^(?>a+)+$`, `^(a++)+$`} {
		_, err := regexp.Compile(pattern)
		fmt.Printf("  %-24s %v\n", pattern, err)
	}
}
