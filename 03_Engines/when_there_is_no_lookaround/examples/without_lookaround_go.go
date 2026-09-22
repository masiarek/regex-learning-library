// The same three jobs in Go, whose regexp is RE2 and has no lookaround either.
package main

import (
	"fmt"
	"regexp"
	"sort"
)

func main() {
	// 1. Several rules at once. Go has no RegexSet, so the set is a slice --
	//    which reads the same and still reports WHICH rule failed.
	rules := map[string]*regexp.Regexp{
		"a lowercase letter": regexp.MustCompile(`[a-z]`),
		"an uppercase letter": regexp.MustCompile(`[A-Z]`),
		"a digit":             regexp.MustCompile(`[0-9]`),
	}
	for _, pw := range []string{"Sunshine1", "sunshine1"} {
		var missing []string
		for name, re := range rules {
			if !re.MatchString(pw) {
				missing = append(missing, name)
			}
		}
		// Go randomises map iteration on purpose, so the report is sorted --
		// otherwise this example would print a different order every run.
		sort.Strings(missing)
		fmt.Printf("%-10s accepted %v\n", pw, len(missing) == 0 && len(pw) >= 8)
		for _, m := range missing {
			fmt.Printf("%-10s missing %s\n", "", m)
		}
	}

	// 2. "X not followed by Y": match the optional tail, then test it.
	amount := regexp.MustCompile(`(\d+)( EUR)?`)
	for _, m := range amount.FindAllStringSubmatch("250 EUR and 90 USD", -1) {
		if m[2] == "" {
			fmt.Println("not in EUR:", m[1])
		}
	}

	// 3. "X preceded by Y": capture the prefix and use the submatch indices.
	priced := regexp.MustCompile(`EUR (\d+)`)
	text := "EUR 250 USD 90"
	for _, loc := range priced.FindAllStringSubmatchIndex(text, -1) {
		fmt.Printf("after EUR: %q at byte %d\n", text[loc[2]:loc[3]], loc[2])
	}
}
