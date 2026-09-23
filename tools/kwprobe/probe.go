// The Go column of tools/kwprobe/run.py. One cell per row on stdout.
//
// Go's regexp has no replace-first, so a replace row finds the first match
// and expands the template over it with Regexp.Expand -- the same template
// language ReplaceAllString uses ($1, ${name}, $$).
package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func decode(s string) string {
	var out strings.Builder
	r := []rune(s)
	for i := 0; i < len(r); i++ {
		c := r[i]
		if c == '\\' && i+1 < len(r) {
			switch r[i+1] {
			case 'n':
				out.WriteRune('\n')
				i++
				continue
			case 'r':
				out.WriteRune('\r')
				i++
				continue
			case 't':
				out.WriteRune('\t')
				i++
				continue
			case '\\':
				out.WriteRune('\\')
				i++
				continue
			case 'u':
				if i+2 < len(r) && r[i+2] == '{' {
					j := i + 3
					for j < len(r) && r[j] != '}' {
						j++
					}
					v, _ := strconv.ParseInt(string(r[i+3:j]), 16, 32)
					out.WriteRune(rune(v))
					i = j
					continue
				}
			}
		}
		out.WriteRune(c)
	}
	return out.String()
}

func encode(s string) string {
	if s == "" {
		return `""`
	}
	var out strings.Builder
	for _, c := range s {
		switch {
		case c == '\\':
			out.WriteString(`\\`)
		case c == '\n':
			out.WriteString(`\n`)
		case c == '\r':
			out.WriteString(`\r`)
		case c == '\t':
			out.WriteString(`\t`)
		case c < 0x20 || c > 0x7e:
			out.WriteString(fmt.Sprintf(`\u{%X}`, c))
		default:
			out.WriteRune(c)
		}
	}
	return out.String()
}

func main() {
	fh, err := os.Open(os.Args[1])
	if err != nil {
		panic(err)
	}
	sc := bufio.NewScanner(fh)
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		f := strings.Split(line, " :: ")
		for i := range f {
			f[i] = strings.TrimSpace(f[i])
		}
		pattern := f[1]
		hasSubject := len(f) > 2
		subject := ""
		if hasSubject {
			subject = decode(f[2])
		}
		replace, hasReplace, split, skip := "", false, false, false
		opts := []string{}
		if len(f) > 3 {
			opts = f[3:]
		}
		for _, o := range opts {
			switch {
			case strings.HasPrefix(o, "replace="):
				replace, hasReplace = decode(o[8:]), true
			case o == "split":
				split = true
			case strings.HasPrefix(o, "skip="):
				for _, e := range strings.Split(o[5:], ",") {
					if e == "go" {
						skip = true
					}
				}
			}
		}
		if skip {
			fmt.Println("n/a")
			continue
		}
		re, err := regexp.Compile(pattern)
		if err != nil {
			fmt.Println("-")
			continue
		}
		if !hasSubject {
			fmt.Println("ok")
			continue
		}
		switch {
		case hasReplace:
			loc := re.FindStringSubmatchIndex(subject)
			if loc == nil {
				fmt.Println("no")
				continue
			}
			dst := re.Expand(nil, []byte(replace), []byte(subject), loc)
			fmt.Println(encode(subject[:loc[0]] + string(dst) + subject[loc[1]:]))
		case split:
			parts := re.Split(subject, -1)
			for i, p := range parts {
				if p != "" {
					parts[i] = encode(p)
				}
			}
			fmt.Println("[" + strings.Join(parts, ",") + "]")
		default:
			loc := re.FindStringIndex(subject)
			if loc == nil {
				fmt.Println("no")
			} else {
				fmt.Println(encode(subject[loc[0]:loc[1]]))
			}
		}
	}
}
