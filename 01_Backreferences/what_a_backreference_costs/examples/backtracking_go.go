// The pattern that hangs a backtracker, given to an automaton.
package main

import (
	"fmt"
	"regexp"
	"strings"
	"time"
)

func main() {
	subject := strings.Repeat("a", 5000) + "!"
	start := time.Now()
	ok := regexp.MustCompile(`^(a+)+$`).MatchString(subject)
	elapsed := time.Since(start)

	fmt.Printf("match = %v over %d characters\n", ok, len(subject))
	fmt.Println("finished in under 100ms:", elapsed < 100*time.Millisecond)

	// The price of that guarantee is the feature this chapter is about.
	_, err := regexp.Compile(`^(a+)+\1$`)
	fmt.Println("with a backreference:", err)
}
