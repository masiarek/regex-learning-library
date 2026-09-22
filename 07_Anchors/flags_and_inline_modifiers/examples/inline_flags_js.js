// JavaScript's flag letters, and the one place JavaScript is the careful one:
// its idea of a line break is not just \n.
//
// Every construct used here is ES2018 or older, so node 20 and node 24 produce
// byte-identical output. Nothing newer is probed on purpose -- see the page.

const THREE = "one\ntwo\nthree";
const CRLF = "abc\r\ndef";

function esc(s) {
  return '"' + s.replace(/\\/g, "\\\\").replace(/\n/g, "\\n").replace(/\r/g, "\\r") + '"';
}

function show(label, re, subject) {
  const m = re.exec(subject);
  console.log("  " + label.padEnd(30) + " " + (m ? "match " + esc(m[0]) : "no match"));
}

console.log("== the dot: what it excludes ==");
console.log("subject " + esc("one\ntwo"));
show("/one.two/", /one.two/, "one\ntwo");
show("/one.two/s", /one.two/s, "one\ntwo");
console.log("subject " + esc("one\rtwo"));
show("/one.two/", /one.two/, "one\rtwo");
show("/one.two/s", /one.two/s, "one\rtwo");

console.log("== the letter m: line anchors ==");
console.log("subject " + esc(THREE));
show("/^two$/", /^two$/, THREE);
show("/^two$/m", /^two$/m, THREE);
show("/one.two/m", /one.two/m, THREE);
console.log("subject " + esc(CRLF));
show("/^abc$/m", /^abc$/m, CRLF);
show("/^\\w+$/m", /^\w+$/m, CRLF);

console.log("== the letter i, the one uncontested flag ==");
show("/abc/   on ABC", /abc/, "ABC");
show("/abc/i  on ABC", /abc/i, "ABC");

console.log("== no free-spacing mode ==");
show("one line", /(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])/, "due 2026-09-22 ok");
show("/a b/  on " + esc("a b"), /a b/, "a b");
show("/a#b/  on " + esc("a#b"), /a#b/, "a#b");
