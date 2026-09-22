// JavaScript has neither spelling -- and can have the behaviour anyway.
//
// Only the CLASS of the failure is printed, never the engine's wording: error
// text is reworded between releases, and this file's output is an answer key.

for (const source of ["(?>a+)b", "a++b", "a*+b", "a?+b"]) {
  let verdict;
  try {
    new RegExp(source);
    verdict = "compiles";
  } catch (e) {
    verdict = e.constructor.name;
  }
  console.log(source.padEnd(8), verdict);
}

// The workaround: a lookahead that captures, then a backreference that
// re-consumes exactly what it captured.
//
//   (?=(a+))\1
//
// The lookahead runs a+ greedily and succeeds. A lookahead that has succeeded
// is never re-entered to try a shorter alternative, so group 1 is frozen at the
// longest run -- and \1 puts that exact text back on the consuming path. What
// comes out is an atomic group, built from two features JavaScript does have.
function show(source, subject) {
  const found = new RegExp(source).exec(subject);
  console.log(source.padEnd(22), "on", JSON.stringify(subject).padEnd(14), "->",
    found ? JSON.stringify(found[0]) : "no match");
}

show("a+a", "aa");            // the ordinary greedy quantifier gives one back
show("(?=(a+))\\1a", "aa");   // the emulation does not: no match, like a++a
show("(?=(a+))\\1b", "aab");  // and still matches where nothing was given back

// The same trap the real feature has, faithfully reproduced.
show("^[\\w.]+\\.com$", "example.com");
show("^(?=([\\w.]+))\\1\\.com$", "example.com");

// And it cuts the same exponential search. 30 a's and a '!' is 2**30 paths for
// /^(a+)+$/ -- about a minute in node -- and one pass for this.
const hostile = "a".repeat(30) + "!";
console.log("emulated atomic on 30 a's and a '!':",
  /^(?:(?=(a+))\1)+$/.test(hostile));
console.log("emulated atomic on 30 a's:",
  /^(?:(?=(a+))\1)+$/.test("a".repeat(30)));
