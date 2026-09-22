// Go's regexp is RE2: a finite automaton, linear in the subject, and therefore
// with no recursion, no subroutine calls and no backreferences. This is not an
// omission -- balanced parentheses are not a regular language, so no automaton
// of fixed size can recognise them.
//
// What you CAN do is unroll to a fixed depth. This program shows exactly how
// far that gets you.
package main

import (
	"fmt"
	"regexp"
	"strings"
)

func main() {
	fmt.Println("does it COMPILE?")
	for _, p := range []struct{ label, pattern string }{
		{`(?R)`, `\((?:[^()]|(?R))*\)`},
		{`(?1)`, `(\((?:[^()]|(?1))*\))`},
		{`(?&p)`, `(?P<p>\((?:[^()]|(?&p))*\))`},
		{`\g<0>`, `\((?:[^()]|\g<0>)*\)`},
	} {
		_, err := regexp.Compile(p.pattern)
		fmt.Printf("  %-8s %v\n", p.label, err == nil)
	}

	// Unrolled to a fixed depth: the innermost level holds no parentheses at
	// all, and each level wraps the one below it. Four levels is already this
	// long, and it grows by a constant factor per level.
	const limit = 4
	unrolled := unroll(limit)
	fmt.Printf("\nunrolled to depth %d, %d characters of pattern:\n  %s\n", limit, len(unrolled), unrolled)

	re := regexp.MustCompile("^" + unrolled + "$")
	fmt.Println("\nhow deep does it reach?")
	for depth := 1; depth <= limit+2; depth++ {
		subject := strings.Repeat("(", depth) + "a" + strings.Repeat(")", depth)
		fmt.Printf("  depth %d  %-14s %v\n", depth, subject, re.MatchString(subject))
	}

	fmt.Println("\nthe pattern cannot be written to reach every depth: each level")
	fmt.Println("is another copy of the one below it, and there is no last level.")
}

// unroll builds a pattern that matches parentheses nested at most `depth` deep.
func unroll(depth int) string {
	inner := `[^()]*`
	for i := 1; i < depth; i++ {
		inner = `(?:[^()]|\(` + inner + `\))*`
	}
	return `\(` + inner + `\)`
}

