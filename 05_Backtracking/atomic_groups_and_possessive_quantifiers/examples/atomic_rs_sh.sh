#!/usr/bin/env bash
# Rust has no regular expressions in its standard library, so the question is
# one about crates -- and the two answer differently. --locked because the
# error text below is part of the answer key.
set -eu
cargo run --locked --quiet --manifest-path ../../../rust-demo/Cargo.toml --bin atomic_group
