// JavaScript spells the replacement with $, and has one form the others lack.
const iban = "DE44 5001 0517 5407 3249 31";
console.log(iban.replace(/(\d{4}) (\d{4})/, "$1-$2"));

console.log("2026-09".replace(/(?<y>\d{4})-(?<m>\d{2})/, "$<m>/$<y>"));
console.log("order 42".replace(/\d+/, "[$&]"));   // $& is the whole match
console.log("cost".replace(/^/, "$$"));           // $$ is one literal dollar

// A function replacement is the escape hatch every engine here needs sooner or
// later: the groups arrive as arguments and you compute the answer.
console.log("order 42".replace(/(\d+)/, (_, n) => Number(n) * 2));
