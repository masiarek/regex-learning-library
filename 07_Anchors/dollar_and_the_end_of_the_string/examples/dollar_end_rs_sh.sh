#!/usr/bin/env bash
set -eu
cargo run --locked --quiet --manifest-path ../../../rust-demo/Cargo.toml --bin dollar_anchor
