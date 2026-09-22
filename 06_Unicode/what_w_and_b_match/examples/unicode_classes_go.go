// What \w, \d, \s and \b match in Go's regexp (RE2) -- ASCII, with no switch.
//
// Every character is built from its code point with string(rune(...)), never
// written literally, and every matched token is escaped back to ASCII, so this
// file and everything it prints stay inside 7 bits.
package main

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

type probe struct {
	label string
	cp    rune
}

var probes = []probe{
	{"U+0041 LATIN CAPITAL LETTER A", 0x0041},
	{"U+00E9 LATIN SMALL LETTER E WITH ACUTE", 0x00E9},
	{"U+0301 COMBINING ACUTE ACCENT", 0x0301},
	{"U+0660 ARABIC-INDIC DIGIT ZERO", 0x0660},
	{"U+FF11 FULLWIDTH DIGIT ONE", 0xFF11},
	{"U+00A0 NO-BREAK SPACE", 0x00A0},
	{"U+3000 IDEOGRAPHIC SPACE", 0x3000},
}

func esc(s string) string {
	var b strings.Builder
	for _, r := range s {
		if r >= 0x20 && r <= 0x7E {
			b.WriteRune(r)
		} else {
			fmt.Fprintf(&b, `\u%04X`, r)
		}
	}
	return b.String()
}

// hit answers "does this class match this one character?", and reports a class
// the engine refuses to compile rather than panicking on it.
func hit(class, s string) string {
	re, err := regexp.Compile(`\A(?:` + class + `)\z`)
	if err != nil {
		return "ERR"
	}
	if re.MatchString(s) {
		return "yes"
	}
	return "no"
}

func pad(s string, n int) string {
	if len(s) >= n {
		return s
	}
	return s + strings.Repeat(" ", n-len(s))
}

func table(title, w, d, sp string) {
	fmt.Println(title)
	width := len(w)
	for _, s := range []string{d, sp} {
		if len(s) > width {
			width = len(s)
		}
	}
	width += 2
	fmt.Println(pad("", 40) + pad(w, width) + pad(d, width) + sp)
	for _, p := range probes {
		c := string(p.cp)
		fmt.Println(pad(p.label, 40) + pad(hit(w, c), width) + pad(hit(d, c), width) + hit(sp, c))
	}
	fmt.Println()
}

func main() {
	// "naive" with U+00EF LATIN SMALL LETTER I WITH DIAERESIS in the middle.
	subject := "na" + string(rune(0x00EF)) + "ve reader"
	// "012" written with U+0660..U+0662 ARABIC-INDIC DIGIT ZERO..TWO.
	arabicIndic := string(rune(0x0660)) + string(rune(0x0661)) + string(rune(0x0662))

	table(`the shorthands, and there is no flag that changes them:`, `\w`, `\d`, `\s`)
	table(`the Unicode categories, which is all RE2 offers:`, `\pL`, `\p{Nd}`, `\p{Zs}`)

	fmt.Println(`RE2 has no binary Unicode properties -- ERR means "failed to compile":`)
	for _, class := range []string{`\p{White_Space}`, `\p{Alphabetic}`, `\p{Word}`} {
		_, err := regexp.Compile(class)
		verdict := "compiles"
		if err != nil {
			verdict = "ERR"
		}
		fmt.Println("  " + pad(class, 18) + verdict)
	}
	fmt.Println()

	fmt.Println(`\b\w+\b over 'na' U+00EF 've reader' -- how many words?`)
	for _, pat := range []string{`\b\w+\b`, `\b[\pL\pN_]+\b`} {
		found := regexp.MustCompile(pat).FindAllString(subject, -1)
		shown := make([]string, len(found))
		for i, t := range found {
			shown[i] = esc(t)
		}
		fmt.Printf("  %s -> %d   %s\n", pad(pat, 16), len(found), strings.Join(shown, " "))
	}
	fmt.Println()

	fmt.Println(`\d and the number that follows it (subject is U+0660 U+0661 U+0662):`)
	fmt.Println(`  \d+          -> ` + hit(`\d+`, arabicIndic))
	fmt.Println(`  \p{Nd}+      -> ` + hit(`\p{Nd}+`, arabicIndic))
	if n, err := strconv.Atoi(arabicIndic); err != nil {
		fmt.Println(`  strconv.Atoi -> error`)
	} else {
		fmt.Println(`  strconv.Atoi -> `, n)
	}
}
