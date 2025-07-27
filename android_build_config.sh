#!/bin/bash
# RustDesk Android Build Configuration

# Environment Variables (matching GitHub Actions workflow)
export RUST_VERSION="1.75"
export CARGO_NDK_VERSION="3.1.2"
export LLVM_VERSION="15.0.6"
export FLUTTER_VERSION="3.24.5"
export ANDROID_FLUTTER_VERSION="3.24.5"
export VCPKG_COMMIT_ID="6f29f12e82a8293156836ad81cc9bf5af41fe836"
export VERSION="1.4.1"
export NDK_VERSION="r27c"

# Set paths
export VCPKG_ROOT="$HOME/vcpkg"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/$NDK_VERSION"
export ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"

# Add to PATH
export PATH="$VCPKG_ROOT:$PATH"
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

echo "✅ Android build environment loaded"
echo "📱 NDK Version: $NDK_VERSION"
echo "🦀 Rust Version: $RUST_VERSION"
echo "💙 Flutter Version: $FLUTTER_VERSION"
