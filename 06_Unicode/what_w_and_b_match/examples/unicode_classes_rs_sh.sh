#!/usr/bin/env bash
# Rust has no regex in its standard library, so this is a question about crates.
# --locked, because the crate's error messages are printed on the page.
set -eu
cargo run --locked --quiet --manifest-path ../../../rust-demo/Cargo.toml --bin unicode_classes
