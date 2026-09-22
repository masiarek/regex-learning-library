// Go's regexp is RE2, and RE2 did not copy Perl's newline clause: by default
// `$` is the end of the text, full stop. The documented wording is "like \z,
// not \Z" -- and \Z is not even a thing you can write here.
package main

import (
	"fmt"
	"regexp"
)

var subjects = []string{"1", "1\n", "1\nrm -rf /"}

func row(label string, cells ...string) {
	fmt.Printf("%-30s%-8s%-8s%s\n", label, cells[0], cells[1], cells[2])
}

func verdicts(pattern string) []string {
	re, err := regexp.Compile(pattern)
	if err != nil {
		// Normalised, so the page does not depend on one Go release's wording.
		return []string{"error", "error", "error"}
	}
	cells := make([]string, len(subjects))
	for i, s := range subjects {
		if re.MatchString(s) {
			cells[i] = "match"
		} else {
			cells[i] = "no"
		}
	}
	return cells
}

func main() {
	fmt.Println("go regexp")
	row("pattern", `"1"`, `"1\n"`, `"1\nrm -rf /"`)
	row(`^\d+$`, verdicts(`^\d+$`)...)
	row(`\A\d+\z`, verdicts(`\A\d+\z`)...)
	row(`\A\d+\Z`, verdicts(`\A\d+\Z`)...)
	row(`(?m)^\d+$`, verdicts(`(?m)^\d+$`)...)

	// `\Z` is refused rather than silently meaning something else. RE2 has \A
	// and \z and stops there, which is the honest set: every anchor it offers
	// is about the text, never about a line, unless you ask for (?m).
	fmt.Println()
	if _, err := regexp.Compile(`\A\d+\Z`); err != nil {
		fmt.Printf("%-30s%s\n", `\A\d+\Z`, "refused at compile time")
	} else {
		fmt.Printf("%-30s%s\n", `\A\d+\Z`, "compiles")
	}

	// The flag letters. Go spells the line-anchor flag m and the dot flag s,
	// inline rather than beside the pattern.
	fmt.Println()
	row("flag", "none", "(?m)", "(?s)")
	row(`^\d+$ on "1\nrm -rf /"`,
		match(`^\d+$`, "1\nrm -rf /"),
		match(`(?m)^\d+$`, "1\nrm -rf /"),
		match(`(?s)^\d+$`, "1\nrm -rf /"))
	row(`a.b on "a\nb"`,
		match(`a.b`, "a\nb"),
		match(`(?m)a.b`, "a\nb"),
		match(`(?s)a.b`, "a\nb"))
}

func match(pattern, subject string) string {
	if regexp.MustCompile(pattern).MatchString(subject) {
		return "match"
	}
	return "no"
}
