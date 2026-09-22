#!/usr/bin/env bash
# Rust's two answers, side by side: the automaton that cannot backtrack, and the
# backtracker that counts its steps. --locked, because the error message below
# goes on a page and a silent minor bump that rewords it is the drift this
# library exists to catch.
set -eu
cargo run --locked --quiet --manifest-path ../../../rust-demo/Cargo.toml --bin redos_lookahead
