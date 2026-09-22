// JavaScript has \p{...}, and it is invisible without the u flag.
//
// `\p` is not an error in a legacy (non-unicode) pattern: Annex B's
// IdentityEscape rule turns it into the plain letter `p`, and `{L}` is not a
// valid quantifier so it stays literal too. /\p{L}/ therefore matches the
// four-character text "p{L}" -- silently, with no warning anywhere.

const CAST = [0x0009, 0x0037, 0x0041, 0x00A0, 0x00E9, 0x03B1, 0x0394, 0x0416, 0x0660, 0x2014, 0x4E2D];
const hex = (cp) => cp.toString(16).toUpperCase().padStart(4, "0");

console.log("without the u flag, \\p is the letter p");
console.log("  /^\\p{L}$/ on the 4-character text p{L}   ", /^\p{L}$/.test("p{L}"));
console.log("  /^\\p{L}$/ on U+03B1                      ", /^\p{L}$/.test(String.fromCodePoint(0x03B1)));
console.log("  /^\\P{L}$/ on the 4-character text P{L}   ", /^\P{L}$/.test("P{L}"));

// Only the compile answer is printed, never the engine's wording: V8 rewords
// its messages between releases, and this key has to hold on two node versions.
const SPELLINGS = [
  "\\p{L}", "\\pL", "\\p{Lu}", "\\p{Nd}", "\\p{P}",
  "\\p{Greek}", "\\p{Script=Greek}", "\\p{sc=Greek}", "\\p{Script_Extensions=Greek}",
  "\\p{Alphabetic}", "\\p{Alpha}", "\\p{White_Space}", "\\p{gc=Lu}",
  "[\\p{L}\\p{Nd}]", "\\X",
];

console.log("\nwith the u flag, does it compile?");
const usable = [];
for (const spelling of SPELLINGS) {
  let re = null;
  try {
    re = new RegExp("^" + spelling + "$", "u");
  } catch {
    console.log(`  ${spelling.padEnd(28)}refused`);
    continue;
  }
  console.log(`  ${spelling.padEnd(28)}compiles`);
  usable.push([spelling, re]);
}

console.log("\nand what the ones that compile match");
for (const [spelling, re] of usable) {
  const hit = CAST.filter((cp) => re.test(String.fromCodePoint(cp))).map(hex);
  console.log(`  ${spelling.padEnd(28)}${hit.join(" ") || "(nothing)"}`);
}
