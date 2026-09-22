// One engine, both rules. Go's regexp answers the same question two ways: it
// is leftmost-FIRST by default, like Perl and Python, and Longest() switches
// the same compiled pattern to the leftmost-LONGEST rule POSIX specifies.
//
// That makes it the cheapest proof on the page that the two rules are a choice
// the engine makes, not something the pattern says.
package main

import (
	"fmt"
	"regexp"
)

// found returns the text of the first match, or "-" when there is none.
func found(pattern, subject string, longest bool) string {
	re := regexp.MustCompile(pattern)
	if longest {
		re.Longest()
	}
	loc := re.FindStringIndex(subject)
	if loc == nil {
		return "-"
	}
	return subject[loc[0]:loc[1]]
}

func main() {
	cases := []struct{ pattern, subject string }{
		{`a|ab`, `ab`},
		{`ab|a`, `ab`},
		{`[0-9]+|[0-9]+\.[0-9]+`, `v 3.14 w`},
		{`[0-9]+\.[0-9]+|[0-9]+`, `v 3.14 w`},
	}
	fmt.Printf("%-22s %-9s %-9s %s\n", "pattern", "subject", "default", "Longest()")
	for _, c := range cases {
		fmt.Printf("%-22s %-9s %-9s %s\n", c.pattern, c.subject,
			found(c.pattern, c.subject, false), found(c.pattern, c.subject, true))
	}

	// Where the match ends, not just what it says -- a|ab against ab stops
	// after one byte under the default rule and after two under Longest().
	fmt.Println()
	for _, longest := range []bool{false, true} {
		re := regexp.MustCompile(`a|ab`)
		label := "default  "
		if longest {
			re.Longest()
			label = "Longest()"
		}
		loc := re.FindStringIndex("ab")
		fmt.Printf("%s a|ab on ab ends at [%d,%d)\n", label, loc[0], loc[1])
	}

	// Longest() moves the WHOLE match. It does not bring POSIX's rule for
	// subexpressions with it: the groups keep their leftmost-first assignment.
	fmt.Println()
	fmt.Println("(a|ab)(c|bcd)(d*) on abcd")
	for _, longest := range []bool{false, true} {
		re := regexp.MustCompile(`(a|ab)(c|bcd)(d*)`)
		label := "default  "
		if longest {
			re.Longest()
			label = "Longest()"
		}
		g := re.FindStringSubmatch("abcd")
		fmt.Printf("%s whole=%s g1=%s g2=%s g3=%s\n", label, g[0], g[1], g[2], g[3])
	}
}
