// The JavaScript column of tools/kwprobe/run.py. One cell per row on stdout.
//
// JavaScript has no inline flags, so a row passes them as `node=FLAGS`. With
// no `g` flag, String.prototype.replace touches the first match only, which
// is the question every replace row asks.
"use strict";
const fs = require("fs");

function decode(s) {
  let out = "";
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (c === "\\" && i + 1 < s.length) {
      const n = s[i + 1];
      if (n === "n") { out += "\n"; i++; continue; }
      if (n === "r") { out += "\r"; i++; continue; }
      if (n === "t") { out += "\t"; i++; continue; }
      if (n === "\\") { out += "\\"; i++; continue; }
      if (n === "u" && s[i + 2] === "{") {
        const j = s.indexOf("}", i);
        out += String.fromCodePoint(parseInt(s.slice(i + 3, j), 16));
        i = j; continue;
      }
    }
    out += c;
  }
  return out;
}

function encode(s) {
  if (s === "") return '""';
  let out = "";
  for (const c of s) {
    const o = c.codePointAt(0);
    if (c === "\\") out += "\\\\";
    else if (c === "\n") out += "\\n";
    else if (c === "\r") out += "\\r";
    else if (c === "\t") out += "\\t";
    else if (o < 0x20 || o > 0x7e) out += "\\u{" + o.toString(16).toUpperCase() + "}";
    else out += c;
  }
  return out;
}

for (const raw of fs.readFileSync(process.argv[2], "utf8").split("\n")) {
  const line = raw.trim();
  if (!line || line.startsWith("#")) continue;
  const f = line.split(" :: ").map((x) => x.trim());
  const pattern = f[1];
  const subject = f.length > 2 ? decode(f[2]) : null;
  let replace = null, split = false, flags = "", skip = false;
  for (const o of f.slice(3)) {
    if (o.startsWith("replace=")) replace = decode(o.slice(8));
    else if (o === "split") split = true;
    else if (o.startsWith("node=")) flags = o.slice(5);
    else if (o.startsWith("skip=") && o.slice(5).split(",").includes("node")) skip = true;
  }
  if (skip) { console.log("n/a"); continue; }
  let re;
  try { re = new RegExp(pattern, flags); } catch { console.log("-"); continue; }
  if (subject === null) { console.log("ok"); continue; }
  try {
    if (replace !== null) {
      if (!re.test(subject)) { console.log("no"); continue; }
      re.lastIndex = 0;
      console.log(encode(subject.replace(re, replace)));
    } else if (split) {
      console.log("[" + subject.split(re).map((p) => (p === "" || p === undefined) ? "" : encode(p)).join(",") + "]");
    } else {
      const m = re.exec(subject);
      console.log(m === null ? "no" : encode(m[0]));
    }
  } catch { console.log("err"); }
}
