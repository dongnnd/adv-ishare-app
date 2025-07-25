#!/bin/bash

# Wrapper script cho flutter_rust_bridge_codegen với ffigen x86_64
# Sử dụng: ./flutter_rust_bridge_fixed.sh [options]

set -e

# Set môi trường cho Apple Silicon
export LIBCLANG_PATH="/opt/homebrew/opt/llvm/lib"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/llvm/lib"

# Tạo symlink tạm thời cho flutter pub run ffigen
FLUTTER_FFIGEN_PATH="$(pwd)/flutter/ffigen_x86_64.sh"

# Tạo symlink trong PATH để flutter_rust_bridge_codegen tìm thấy
export PATH="$(pwd)/flutter:$PATH"

# Tạo symlink cho flutter pub run ffigen
ln -sf flutter/ffigen_x86_64.sh flutter/flutter_pub_run_ffigen

# Chạy flutter_rust_bridge_codegen với môi trường arm64
arch -arm64 flutter_rust_bridge_codegen "$@" 