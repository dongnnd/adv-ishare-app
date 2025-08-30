#!/usr/bin/env bash
export RUSTFLAGS="${RUSTFLAGS:--C link-arg=-Wl,-z,max-page-size=16384}"
cargo ndk --platform 21 --target x86_64-linux-android build --release --features flutter
