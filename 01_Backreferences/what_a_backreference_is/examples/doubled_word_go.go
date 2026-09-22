// Go's regexp is RE2: it promises to answer in time linear in the subject, and
// a backreference is exactly the feature that promise cannot survive.
package main

import (
	"fmt"
	"regexp"
)

func main() {
	if _, err := regexp.Compile(`\b(\w+) \1\b`); err != nil {
		fmt.Println("compile:", err)
	}

	// What RE2 offers instead: say the repetition out loud, or do the compare
	// in Go once the candidates are narrowed down.
	re := regexp.MustCompile(`\b(\w+) (\w+)\b`)
	text := "the the quick brown fox fox jumped"
	for _, m := range re.FindAllStringSubmatch(text, -1) {
		if m[1] == m[2] {
			fmt.Printf("doubled by hand: %q\n", m[0])
		}
	}
}
