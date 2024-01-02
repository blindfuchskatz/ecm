#!/bin/bash

echo -e "\e[32m-------------------- Compile ecm --------------------\e[0m"

set -o errexit
set -o nounset
set -o pipefail

user_input=${1:-input_missing}

if [ "$user_input"  == "x64" ]; then
    echo -e "\e[32mBuild for target architecture $user_input ... \e[0m"
    RUSTFLAGS="-D warnings" cargo build

elif [ "$user_input"  == "armv7" ]; then
    echo -e "\e[32mBuild for target architecture $user_input ... \e[0m"
    RUSTFLAGS="-D warnings" cargo build --target=armv7-unknown-linux-gnueabihf

elif [ "$user_input"  == "clean" ]; then
    echo -e "\e[32mClean\e[0m"
    cargo clean
else
    echo -e "\e[31mMissing user input\e[0m"
    echo -e "\e[31mUsage ${0} <x86/arm/clean>\e[0m"
fi
