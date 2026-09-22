// JavaScript has the same \1, and one rule of its own that bites later.
const text = "the the quick brown fox fox jumped over the lazy dog dog";

for (const m of text.matchAll(/\b(\w+) \1\b/g)) {
  console.log(`numbered   offset ${String(m.index).padStart(2)}  '${m[0]}'  group 1 = '${m[1]}'`);
}

// Named groups use \k<name> in the pattern.
console.log("named     ", /\b(?<word>\w+) \k<word>\b/.test("ho ho"));

// THE difference: a backreference to a group that never took part matches the
// empty string here, where Perl, Python, Ruby and Java all fail the match.
console.log("unset group:", /^(z)?\1$/.test("") ? "empty match" : "failed");
