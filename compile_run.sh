#!/bin/bash
echo -e "\e[32m-------------------- Static code analyse --------------------\e[0m"
cargo clippy -- -D clippy::all

echo -e "\e[32m-------------------- Compile --------------------\e[0m"
RUSTFLAGS="-D warnings" cargo build

echo -e "\e[32m-------------------- Run electricity consumption monitor --------------------\e[0m"
 ./target/debug/main