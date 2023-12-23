#!/bin/bash
echo -e "\e[32m-------------------- Compile and run ecm --------------------\e[0m"
RUSTFLAGS="-D warnings" cargo build