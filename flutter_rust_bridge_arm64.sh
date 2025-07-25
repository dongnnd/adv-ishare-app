#!/bin/bash

# Wrapper script cho flutter_rust_bridge_codegen với Flutter arm64
# Sử dụng: ./flutter_rust_bridge_arm64.sh [options]

set -e

# Set môi trường cho Apple Silicon
export LIBCLANG_PATH="/opt/homebrew/opt/llvm/lib"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/llvm/lib"

# Tạo symlink tạm thời cho flutter để flutter_rust_bridge_codegen sử dụng
FLUTTER_ARM64_PATH="$(pwd)/flutter/flutter_arm64.sh"

# Thêm thư mục flutter vào PATH để flutter_rust_bridge_codegen tìm thấy
export PATH="$(pwd)/flutter:$PATH"

# Chạy flutter_rust_bridge_codegen với môi trường arm64
arch -arm64 flutter_rust_bridge_codegen "$@" 