#!/usr/bin/env bash
export RUSTFLAGS="${RUSTFLAGS:--C link-arg=-Wl,-z,max-page-size=16384}"
cargo ndk --platform 21 --target i686-linux-android build --release --features flutter
