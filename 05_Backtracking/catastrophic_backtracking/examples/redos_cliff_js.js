// The same cliff, in the engine that runs on the thread serving your users.
//
// JavaScript has no atomic group and no possessive quantifier, so the escape
// hatch Python and Perl offer is not available here: the pattern has to be
// rewritten, or the work has to be moved off the request thread.
//
// No timing is recorded. Each probe runs in a child process with a fixed cap,
// and the key holds "match", "no match" or "no answer" -- the two subject sizes
// sit far enough either side of the cliff that every machine agrees.

const { spawnSync } = require('child_process');

const CAP_MS = 3000;

const EMAIL = "^([a-zA-Z0-9_\\.\\-])+\\@(([a-zA-Z0-9\\-])+\\.)+([a-zA-Z]{2,4})+$";
const EMAIL_FIXED = "^[a-zA-Z0-9_.-]+@([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,4}$";

const SMALL = 'a'.repeat(16) + '!';
const GOOD = 'a'.repeat(120);              // this one MATCHES, and that is the point
const HOSTILE = 'a'.repeat(120) + '!';     // one character that cannot match
const BLANKS = ' '.repeat(120) + '!';
const MAIL_SMALL = 'a@a.' + 'a'.repeat(20) + '!';
const MAIL_HOSTILE = 'a@a.' + 'a'.repeat(120) + '!';

// The child is a fresh node that compiles the pattern, tests it, and prints one
// word. Anything else -- killed, crashed, silent -- counts as "no answer".
const CHILD = 'const a = process.argv.slice(1); console.log(new RegExp(a[0]).test(a[1]))';

function probe(pattern, subject) {
  const done = spawnSync(process.execPath, ['-e', CHILD, pattern, subject],
                         { timeout: CAP_MS, encoding: 'utf8' });
  if (done.status !== 0) return 'no answer';
  return done.stdout.trim() === 'true' ? 'match' : 'no match';
}

function pad(s, n) { return (s + ' '.repeat(n)).slice(0, Math.max(n, s.length)); }

function table(title, rows) {
  console.log(title);
  for (const [pattern, shown, subject, described] of rows) {
    console.log('  ' + pad(shown || pattern, 24) + ' ' + pad(described, 22) + ' ' + probe(pattern, subject));
  }
}

console.log('"no answer" means the child was still searching after ' + (CAP_MS / 1000) + ' seconds and was killed.');
console.log('');

table('patterns with no backreference, node:', [
  ['^(a+)+$', null, SMALL, "16 a's then '!'"],
  ['^(a+)+$', null, GOOD, "120 a's"],
  ['^(a+)+$', null, HOSTILE, "120 a's then '!'"],
  ['^(a|a)*$', null, HOSTILE, "120 a's then '!'"],
  ['^(\\s*|\\t)+$', null, BLANKS, "120 spaces then '!'"],
  ['^(\\w+\\s?)*$', null, HOSTILE, "120 a's then '!'"],
  ['^([a-z]{2,4})+$', null, HOSTILE, "120 a's then '!'"],
  [EMAIL, 'the email regex', MAIL_SMALL, "a@a. 20 a's then '!'"],
  [EMAIL, 'the email regex', MAIL_HOSTILE, "a@a. 120 a's then '!'"],
]);

console.log('');
table('the same engine, with the pattern changed instead:', [
  ['^a+$', null, HOSTILE, "120 a's then '!'"],
  [EMAIL_FIXED, 'the email regex, fixed', MAIL_HOSTILE, "a@a. 120 a's then '!'"],
  // No atomic group in JavaScript. This is the standard stand-in: a lookahead
  // captures the whole run and a backreference re-consumes exactly it, so there
  // is nothing left to back off into.
  ['^(?:(?=(a+))\\1)+$', 'atomic, emulated', HOSTILE, "120 a's then '!'"],
]);
