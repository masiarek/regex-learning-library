// The same four questions, in JavaScript, so a reader can see that the
// backtracking engines agree with each other about greedy and lazy.
//
// Nothing here uses syntax newer than ES2018: the interesting differences in
// this area are between ENGINES, not between language editions.

const subject = "<b>bold</b>";
const patterns = [/<.+>/, /<.+?>/, /<[^>]+>/];

console.log("subject      ", subject);
for (const re of patterns) {
  const first = subject.match(re)[0];
  const all = subject.match(new RegExp(re.source, "g"));
  console.log(
    "  " + re.source.padEnd(9) +
    " first " + JSON.stringify(first) +
    "  all " + JSON.stringify(all) +
    "  stripped " + JSON.stringify(subject.replace(new RegExp(re.source, "g"), ""))
  );
}

// The same four spellings with no delimiters in sight.
console.log("subject      ", "aaa");
for (const re of [/a+/, /a+?/, /a*?/, /a{1,3}?/]) {
  console.log("  " + re.source.padEnd(9) + " first " + JSON.stringify("aaa".match(re)[0]));
}

// Which delimiter closes the capture -- the case where the `?` changes the
// answer rather than the work.
const line = 'name="ada", role="pilot"';
console.log("subject      ", line);
for (const re of [/"(.*)"/, /"(.*?)"/, /"([^"]*)"/]) {
  console.log("  " + re.source.padEnd(9) + " group 1 " + JSON.stringify(line.match(re)[1]));
}

// A lazy quantifier with nothing after it stops at once, so it matches the
// empty string; anchor the pattern and it has to cross the whole line anyway.
console.log("subject      ", line);
for (const re of [/name=.*/, /name=.*?/, /name=.*$/, /name=.*?$/]) {
  console.log("  " + re.source.padEnd(9) + " match   " + JSON.stringify(line.match(re)[0]));
}
