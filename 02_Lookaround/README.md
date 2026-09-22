# Lookaround

An assertion that tests the text beside the current position and consumes none of it. Four spellings — `(?=…)`, `(?!…)`, `(?<=…)`, `(?<!…)` — and one genuinely hard question underneath them: how wide may a lookbehind be?

| Lesson | The question |
| --- | --- |
| [Lookahead and lookbehind](lookahead_and_lookbehind/README.md) | What zero-width buys you, the two traps that catch everyone (`\d+(?! EUR)` matching `25`), and the width rule in seven engines. |

**If you came looking for forward references:** they are in [the backreferences chapter](../01_Backreferences/forward_references/README.md). Lookaround is about *position*; a forward reference is about *captured text*. The first lesson there sets the four names side by side.
