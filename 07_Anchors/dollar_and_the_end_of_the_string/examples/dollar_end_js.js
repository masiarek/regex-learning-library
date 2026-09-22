// `$` in JavaScript really is the end of the string -- no newline clause.
// JavaScript is the one engine here whose `^...$` means what people think it
// means, and the one engine with no `\A` and no `\z` to fall back on.

const subjects = ["1", "1\n", "1\nrm -rf /"];
const shown = ['"1"', '"1\\n"', '"1\\nrm -rf /"'];

function row(label, a, b, c) {
  console.log(label.padEnd(30) + a.padEnd(8) + b.padEnd(8) + c);
}

function verdicts(re) {
  return subjects.map((s) => (re.test(s) ? "match" : "no"));
}

console.log("javascript");
row("pattern", ...shown);
row("/^\\d+$/", ...verdicts(/^\d+$/));
row("/^\\d+$/m", ...verdicts(/^\d+$/m));

// There is no \A and no \z. In a pattern without the `u` flag they are not
// errors either: an unknown escape is the character itself, so /\A\d+\z/ is
// the literal letter A, some digits, and the literal letter z.
console.log();
console.log('/\\A\\d+\\z/ on "A1z"'.padEnd(30) + (/\A\d+\z/.test("A1z") ? "match" : "no"));
console.log('/\\A\\d+\\z/ on "1"'.padEnd(30) + (/\A\d+\z/.test("1") ? "match" : "no"));
let uflag;
try {
  new RegExp("\\A\\d+\\z", "u");
  uflag = "compiles";
} catch (e) {
  uflag = e instanceof SyntaxError ? "SyntaxError" : "other error";
}
console.log('new RegExp("\\\\A\\\\d+\\\\z", "u")'.padEnd(30) + uflag);

// The flag letters. In JavaScript m is the line-anchor flag and s is the dot
// flag, the same way round as Perl and Python -- and the opposite of Ruby.
console.log();
row("flag", "none", "m", "s");
row('^\\d+$ on "1\\nrm -rf /"',
  /^\d+$/.test("1\nrm -rf /") ? "match" : "no",
  /^\d+$/m.test("1\nrm -rf /") ? "match" : "no",
  /^\d+$/s.test("1\nrm -rf /") ? "match" : "no");
row('a.b on "a\\nb"',
  /a.b/.test("a\nb") ? "match" : "no",
  /a.b/m.test("a\nb") ? "match" : "no",
  /a.b/s.test("a\nb") ? "match" : "no");
