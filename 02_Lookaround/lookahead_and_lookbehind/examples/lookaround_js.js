// JavaScript's lookbehind is the permissive one: any width, including a star.
console.log("fixed   :", "EUR 250".match(/(?<=EUR )\d+/)[0]);
console.log("variable:", "EUR    250".match(/(?<=EUR\s{1,4})\d+/)[0]);
console.log("starred :", "EUR      250".match(/(?<=EUR\s*)\d+/)[0]);

// Negative lookbehind, the form worth knowing: "not preceded by".
console.log("negative:", "EUR 250 USD 90".match(/(?<!USD )\d+/g));

// Lookahead is the same everywhere, and stacking is how one pattern says
// several independent rules.
const rules = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
for (const pw of ["Sunshine1", "sunshine1"]) console.log(pw.padEnd(10), rules.test(pw));
