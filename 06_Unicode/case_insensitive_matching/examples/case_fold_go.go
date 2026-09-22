// What (?i) folds in Go's regexp (RE2), and what strings.EqualFold folds.
//
// Both use the same simple-folding orbit, so unlike Python this program's two
// halves agree -- which is its own kind of answer. Characters are built from
// code points and named by code point, so the output is ASCII everywhere.
package main

import (
	"fmt"
	"regexp"
	"strings"
)

// Built from code points: a Go escape for one of these would be a literal
// character in the source, and this library keeps its sources ASCII.
var (
	kelvin    = string(rune(0x212A))
	longS     = string(rune(0x017F))
	sharpS    = string(rune(0x00DF))
	capSharpS = string(rune(0x1E9E))
	dotlessI  = string(rune(0x0131))
	dottedI   = string(rune(0x0130))
	dotAbove  = string(rune(0x0307))
)

type probe struct {
	patName string
	pattern string
	subName string
	subject string
}

func yn(hit bool) string {
	if hit {
		return "yes"
	}
	return "no"
}

func hit(pattern, subject string) string {
	re, err := regexp.Compile("(?i)\\A(?:" + pattern + ")\\z")
	if err != nil {
		return "ERR"
	}
	return yn(re.MatchString(subject))
}

func main() {
	probes := []probe{
		{"k", "k", "U+004B LATIN CAPITAL LETTER K", "K"},
		{"k", "k", "U+212A KELVIN SIGN", kelvin},
		{"s", "s", "U+017F LATIN SMALL LETTER LONG S", longS},
		{"U+00DF", sharpS, "U+1E9E LATIN CAPITAL LETTER SHARP S", capSharpS},
		{"U+1E9E", capSharpS, "U+00DF LATIN SMALL LETTER SHARP S", sharpS},
		{"ss", "ss", "U+00DF LATIN SMALL LETTER SHARP S", sharpS},
		{"[k]", "[k]", "U+212A KELVIN SIGN", kelvin},
		{"[a-z]", "[a-z]", "U+212A KELVIN SIGN", kelvin},
		{"i", "i", "U+0131 LATIN SMALL LETTER DOTLESS I", dotlessI},
		{"i", "i", "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", dottedI},
		{"i U+0307", "i" + dotAbove, "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", dottedI},
	}

	fmt.Println("does (?i) match?          go regexp (RE2), anchored")
	fmt.Printf("%-9s %-46s %s\n", "pattern", "subject", "(?i)")
	for _, p := range probes {
		fmt.Printf("%-9s %-46s %s\n", p.patName, p.subName, hit(p.pattern, p.subject))
	}

	fmt.Println()
	fmt.Println("does (?i) fold the BACKREFERENCE comparison too?")
	_, err := regexp.Compile(`(?i)(a)\1`)
	fmt.Printf("%-12s vs 'a' + U+0041            %v\n", `(?i)(a)\1`, err)

	fmt.Println()
	fmt.Println("one program, two answers about the same pair")
	row := func(label string, strAnswer bool, reAnswer string) {
		fmt.Printf("  %-38s%-8v regex (?i): %s\n", label, strAnswer, reAnswer)
	}
	row("EqualFold: U+00DF and 'ss'", strings.EqualFold(sharpS, "ss"), hit("ss", sharpS))
	row("EqualFold: U+212A and 'k'", strings.EqualFold(kelvin, "k"), hit("k", kelvin))
	row("EqualFold: U+017F and 's'", strings.EqualFold(longS, "s"), hit("s", longS))
	row("ToLower(U+1E9E) == U+00DF", strings.ToLower(capSharpS) == sharpS, hit(sharpS, capSharpS))
	row("ToUpper(U+00DF) is 2 code points", len([]rune(strings.ToUpper(sharpS))) == 2, hit("SS", sharpS))
}
