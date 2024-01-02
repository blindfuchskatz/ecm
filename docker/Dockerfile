FROM rust:1.73.0

RUN apt-get update && apt-get install -y && apt-get clean
RUN apt install libssl-dev build-essential cmake -y && apt-get clean
RUN apt install gcc-arm-linux-gnueabihf -y && apt-get clean

#Rust packages
RUN cargo install cargo-watch
RUN rustup component add clippy
RUN cargo install cargo-tarpaulin
RUN rustup component add rls rust-analysis rust-src
RUN rustup component add rustfmt
RUN rustup target add armv7-unknown-linux-gnueabihf

#End to end tests packages
RUN apt install python3-pip -y && apt-get clean
RUN apt install mosquitto -y && apt-get clean
RUN apt install mosquitto-clients -y && apt-get clean
RUN pip install robotframework --break-system-packages
RUN pip install robotframework-debuglibrary --break-system-packages
RUN pip install reportlab --break-system-packages


