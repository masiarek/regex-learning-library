// JavaScript compiles forward references too -- and answers differently.
for (const s of ["aax", "ax", "aaxx"]) {
  console.log(s.padEnd(5), /^(?:\1x|(a))+$/.test(s) ? "match" : "no match");
}

// This one matches in JavaScript and in no other engine here, for two reasons
// that have nothing to do with forward references:
//   1. a backreference to an unset group matches the empty string, and
//   2. groups inside a quantified group are CLEARED at each iteration,
// so pass 2 sees group 2 as unset again, \2 matches "", and "two" matches.
console.log("onetwo:", /^(\2two|(one))+$/.test("onetwo") ? "match" : "no match");
console.log("cleared each pass:", /^(?:(a)|\1b)+$/.test("ab") ? "match" : "no match");
