FROM rust:1.73.0

RUN apt-get update && apt-get install -y && apt-get clean
RUN apt install libssl-dev build-essential cmake -y && apt-get clean

RUN cargo install cargo-watch
RUN rustup component add clippy
RUN cargo install cargo-tarpaulin
RUN rustup component add rls rust-analysis rust-src
RUN rustup component add rustfmt
RUN rustup target add armv7-unknown-linux-gnueabihf

