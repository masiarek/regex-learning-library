// What /i folds in JavaScript -- and how the `u` flag changes the answer.
//
// Without `u`, canonicalization is toUpperCase() with a rule that refuses any
// mapping which would join an ASCII character to a non-ASCII one. With `u`, it
// is Unicode simple case folding. The two disagree on every interesting pair.
//
// Non-ASCII characters are built from code points and named by code point, so
// the output is ASCII everywhere.

const KELVIN = String.fromCodePoint(0x212a);
const LONG_S = String.fromCodePoint(0x017f);
const SHARP_S = String.fromCodePoint(0x00df);
const CAP_SHARP_S = String.fromCodePoint(0x1e9e);
const DOTLESS_I = String.fromCodePoint(0x0131);
const DOTTED_I = String.fromCodePoint(0x0130);
const DOT_ABOVE = String.fromCodePoint(0x0307);

const probes = [
  ["k", "k", "U+004B LATIN CAPITAL LETTER K", "K"],
  ["k", "k", "U+212A KELVIN SIGN", KELVIN],
  ["s", "s", "U+017F LATIN SMALL LETTER LONG S", LONG_S],
  ["U+00DF", SHARP_S, "U+1E9E LATIN CAPITAL LETTER SHARP S", CAP_SHARP_S],
  ["U+1E9E", CAP_SHARP_S, "U+00DF LATIN SMALL LETTER SHARP S", SHARP_S],
  ["ss", "ss", "U+00DF LATIN SMALL LETTER SHARP S", SHARP_S],
  ["[k]", "[k]", "U+212A KELVIN SIGN", KELVIN],
  ["[a-z]", "[a-z]", "U+212A KELVIN SIGN", KELVIN],
  ["i", "i", "U+0131 LATIN SMALL LETTER DOTLESS I", DOTLESS_I],
  ["i", "i", "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I],
  ["i U+0307", "i" + DOT_ABOVE, "U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE", DOTTED_I],
];

const yn = (hit) => (hit ? "yes" : "no");
const pad = (s, n) => String(s).padEnd(n);
const hit = (pattern, subject, flags) =>
  new RegExp("^(?:" + pattern + ")$", flags).test(subject);

console.log("does /i match?            javascript, anchored");
console.log(pad("pattern", 9) + " " + pad("subject", 46) + " " + pad("/i", 5) + "/iu");
for (const [patName, pattern, subName, subject] of probes) {
  console.log(
    pad(patName, 9) + " " + pad(subName, 46) + " " +
    pad(yn(hit(pattern, subject, "i")), 5) + yn(hit(pattern, subject, "iu")),
  );
}

console.log("");
console.log("does /i fold the BACKREFERENCE comparison too?");
console.log(pad("(a)\\1 /i", 12) + " vs 'a' + U+0041            " +
  yn(new RegExp("(a)\\1", "i").test("aA")));
console.log(pad("(k)\\1 /iu", 12) + " vs 'k' + U+212A            " +
  yn(new RegExp("(k)\\1", "iu").test("k" + KELVIN)));

console.log("");
console.log("one program, two answers about the same pair");
const row = (label, str, flags, re) =>
  console.log("  " + pad(label, 34) + pad(str, 8) + "regex /" + pad(flags + ":", 4) + " " + re);
row("toUpperCase(U+00DF) === 'SS'", SHARP_S.toUpperCase() === "SS", "iu", yn(hit("SS", SHARP_S, "iu")));
row("toLowerCase(U+212A) === 'k'", KELVIN.toLowerCase() === "k", "iu", yn(hit("k", KELVIN, "iu")));
row("toLowerCase(U+212A) === 'k'", KELVIN.toLowerCase() === "k", "i", yn(hit("k", KELVIN, "i")));
row("toUpperCase(U+017F) === 'S'", LONG_S.toUpperCase() === "S", "iu", yn(hit("s", LONG_S, "iu")));
row("toLowerCase(U+1E9E) === U+00DF", CAP_SHARP_S.toLowerCase() === SHARP_S, "iu", yn(hit(SHARP_S, CAP_SHARP_S, "iu")));
