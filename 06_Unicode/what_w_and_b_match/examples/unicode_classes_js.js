// What \w, \d, \s and \b match in JavaScript -- and what the `u` flag does NOT change.
//
// Only ES2018 syntax is used here, so node 20 and node 24 print the same thing.
// Every character is built with String.fromCodePoint, never written literally,
// so this file and everything it prints are pure ASCII.

const probes = [
  ["U+0041 LATIN CAPITAL LETTER A", 0x0041],
  ["U+00E9 LATIN SMALL LETTER E WITH ACUTE", 0x00e9],
  ["U+0301 COMBINING ACUTE ACCENT", 0x0301],
  ["U+0660 ARABIC-INDIC DIGIT ZERO", 0x0660],
  ["U+FF11 FULLWIDTH DIGIT ONE", 0xff11],
  ["U+00A0 NO-BREAK SPACE", 0x00a0],
  ["U+3000 IDEOGRAPHIC SPACE", 0x3000],
];

// "naive" with U+00EF LATIN SMALL LETTER I WITH DIAERESIS in the middle.
const subject = "na" + String.fromCodePoint(0x00ef) + "ve reader";

// "012" written with U+0660..U+0662 ARABIC-INDIC DIGIT ZERO..TWO.
const arabicIndic = String.fromCodePoint(0x0660, 0x0661, 0x0662);

const esc = (s) =>
  Array.from(s)
    .map((c) => {
      const n = c.codePointAt(0);
      return n >= 0x20 && n <= 0x7e ? c : "\\u" + n.toString(16).toUpperCase().padStart(4, "0");
    })
    .join("");

const hit = (src, flags, s) => (new RegExp("^(?:" + src + ")$", flags).test(s) ? "yes" : "no");

function table(title, flags) {
  console.log(title);
  console.log("".padEnd(40) + "\\w".padEnd(5) + "\\d".padEnd(5) + "\\s");
  for (const [label, cp] of probes) {
    const c = String.fromCodePoint(cp);
    console.log(
      label.padEnd(40) +
        hit("\\w", flags, c).padEnd(5) +
        hit("\\d", flags, c).padEnd(5) +
        hit("\\s", flags, c)
    );
  }
  console.log("");
}

table("no flags:", "");
table("the u flag -- identical, because u is about code points, not classes:", "u");

console.log("what you have to write instead (u flag required):");
for (const [label, cp] of probes) {
  const c = String.fromCodePoint(cp);
  console.log(
    "  " +
      label.padEnd(40) +
      "\\p{L} " +
      hit("\\p{L}", "u", c).padEnd(5) +
      "\\p{Nd} " +
      hit("\\p{Nd}", "u", c).padEnd(5) +
      "\\p{White_Space} " +
      hit("\\p{White_Space}", "u", c)
  );
}
console.log("");

console.log("\\b\\w+\\b over 'na' U+00EF 've reader' -- how many words?");
for (const [label, src, flags] of [
  ["\\b\\w+\\b", "\\b\\w+\\b", "g"],
  ["\\b\\w+\\b with u", "\\b\\w+\\b", "gu"],
  ["[\\p{L}\\p{N}_]+", "[\\p{L}\\p{N}_]+", "gu"],
  ["\\b[\\p{L}\\p{N}_]+\\b", "\\b[\\p{L}\\p{N}_]+\\b", "gu"],
]) {
  const found = subject.match(new RegExp(src, flags)) || [];
  console.log("  " + label.padEnd(20) + " -> " + found.length + "   " + found.map(esc).join(" "));
}
console.log("");

console.log("\\d and the number that follows it (subject is U+0660 U+0661 U+0662):");
console.log("  /^\\d+$/       -> " + hit("\\d+", "", arabicIndic));
console.log("  /^\\d+$/u      -> " + hit("\\d+", "u", arabicIndic));
console.log("  /^\\p{Nd}+$/u  -> " + hit("\\p{Nd}+", "u", arabicIndic));
console.log("  Number()      -> " + Number(arabicIndic));
console.log("  parseInt()    -> " + parseInt(arabicIndic, 10));
