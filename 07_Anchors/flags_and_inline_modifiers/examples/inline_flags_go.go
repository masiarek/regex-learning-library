// Go's regexp has no flags argument at all. There is no MustCompile variant
// that takes an int; every flag is spelled inside the pattern. That makes Go
// the cleanest demonstration of why inline flags are the portable habit -- and
// it is also why a Go pattern can be pasted into Perl and keep its meaning.
//
// Standard library only. No version, path or error text is printed: a refusal
// is reported as the fixed words "compile error".
package main

import (
	"fmt"
	"regexp"
	"strings"
)

const three = "one\ntwo\nthree"
const crlf = "abc\r\ndef"

func esc(s string) string {
	r := strings.NewReplacer("\\", "\\\\", "\n", "\\n", "\r", "\\r")
	return "\"" + r.Replace(s) + "\""
}

func show(label, pattern, subject string) {
	re, err := regexp.Compile(pattern)
	if err != nil {
		fmt.Printf("  %-30s compile error\n", label)
		return
	}
	if m := re.FindString(subject); re.MatchString(subject) {
		fmt.Printf("  %-30s match %s\n", label, esc(m))
	} else {
		fmt.Printf("  %-30s no match\n", label)
	}
}

func main() {
	fmt.Println("== the dot: what it excludes ==")
	fmt.Println("subject " + esc("one\ntwo"))
	show("one.two", "one.two", "one\ntwo")
	show("(?s)one.two", "(?s)one.two", "one\ntwo")
	fmt.Println("subject " + esc("one\rtwo"))
	show("one.two", "one.two", "one\rtwo")

	fmt.Println("== the letter m: line anchors ==")
	fmt.Println("subject " + esc(three))
	show("^two$", "^two$", three)
	show("(?m)^two$", "(?m)^two$", three)
	show("(?m)one.two", "(?m)one.two", three)
	fmt.Println("subject " + esc(crlf))
	show("(?m)^abc$", "(?m)^abc$", crlf)
	show("(?m)^abc\\r?$", "(?m)^abc\r?$", crlf)

	fmt.Println("== no free-spacing mode ==")
	show("one line", `(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])`, "due 2026-09-22 ok")
	show("(?x)a b", "(?x)a b", "ab")
	show("a b   on "+esc("a b"), "a b", "a b")

	fmt.Println("== the letter U, Go and Rust only ==")
	show("a+    on "+esc("aaa"), "a+", "aaa")
	show("(?U)a+ on "+esc("aaa"), "(?U)a+", "aaa")

	fmt.Println("== inline and scoped modifiers ==")
	show("abc            on ABC", "abc", "ABC")
	show("(?i)abc        on ABC", "(?i)abc", "ABC")
	show("(?i:b)c        on Bc", "(?i:b)c", "Bc")
	show("(?i:b)c        on bC", "(?i:b)c", "bC")
	show("(?i)ab(?-i:cd) on ABcd", "(?i)ab(?-i:cd)", "ABcd")
	show("(?i)ab(?-i:cd) on ABCD", "(?i)ab(?-i:cd)", "ABCD")
	show("a(?i)bc        on aBC", "a(?i)bc", "aBC")
	show("a(?i)bc        on ABC", "a(?i)bc", "ABC")
	show("(a(?i)b)c      on aBc", "(a(?i)b)c", "aBc")
	show("(a(?i)b)c      on abC", "(a(?i)b)c", "abC")
}
