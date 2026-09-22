// Go's regexp is RE2: a finite automaton, no backtracking, linear in the
// subject. It still has `*?`, and it still gives the same answers as the
// backtracking engines -- because greedy and lazy are a rule about WHICH match
// is preferred, not a strategy for finding one.
//
// Go also ships the other semantics in the same package. CompilePOSIX matches
// leftmost-longest, and that mode has no opinion about `?` at all: the pattern
// compiles, the `?` is accepted, and the answer is the greedy one.
package main

import (
	"fmt"
	"regexp"
)

func main() {
	const subject = "<b>bold</b>"

	fmt.Println("subject:", subject)
	fmt.Printf("  %-9s %-14s %s\n", "pattern", "Compile", "CompilePOSIX")
	for _, pattern := range []string{`<.+>`, `<.+?>`, `<[^>]+>`} {
		first := regexp.MustCompile(pattern).FindString(subject)
		longest := regexp.MustCompilePOSIX(pattern).FindString(subject)
		fmt.Printf("  %-9s %-14q %q\n", pattern, first, longest)
	}

	fmt.Println("subject: aaa")
	fmt.Printf("  %-9s %-14s %s\n", "pattern", "Compile", "CompilePOSIX")
	for _, pattern := range []string{`a+`, `a+?`, `a*?`, `a{1,3}?`} {
		first := regexp.MustCompile(pattern).FindString("aaa")
		longest := regexp.MustCompilePOSIX(pattern).FindString("aaa")
		fmt.Printf("  %-9s %-14q %q\n", pattern, first, longest)
	}

	// The same compiled pattern, switched to longest-match by a method call.
	// Whatever `?` asked for is discarded.
	fmt.Println("subject:", subject, "-- one pattern, before and after Longest()")
	lazy := regexp.MustCompile(`<.+?>`)
	fmt.Printf("  %-9s %-14q ", `<.+?>`, lazy.FindString(subject))
	lazy.Longest()
	fmt.Printf("%q after Longest()\n", lazy.FindString(subject))
}
