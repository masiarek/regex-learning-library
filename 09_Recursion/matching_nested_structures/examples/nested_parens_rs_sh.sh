#!/usr/bin/env bash
# Rust has no regex in its standard library, so this is a question about crates.
set -eu
cargo run --locked --quiet --manifest-path ../../../rust-demo/Cargo.toml --bin recursion
