#!/bin/bash

# Script thông minh để generate flutter_rust_bridge code với libclang đúng kiến trúc
# Sử dụng: ./gen_bridge_fixed.sh

set -e

# Đảm bảo chạy từ thư mục gốc của dự án
if [[ ! -f "Cargo.toml" ]]; then
    echo "Lỗi: Chạy script này từ thư mục gốc của dự án rustdesk"
    exit 1
fi

# Kiểm tra kiến trúc
ARCH=$(uname -m)
echo "Architecture: $ARCH"

# Set môi trường dựa trên kiến trúc
if [[ "$ARCH" == "arm64" ]]; then
    # Apple Silicon - dùng libclang arm64
    export LIBCLANG_PATH="/opt/homebrew/opt/llvm/lib"
    export DYLD_LIBRARY_PATH="/opt/homebrew/opt/llvm/lib"
    echo "Using ARM64 libclang: $LIBCLANG_PATH"
else
    # Intel Mac - dùng libclang x86_64
    export LIBCLANG_PATH="/usr/local/opt/llvm/lib"
    export DYLD_LIBRARY_PATH="/usr/local/opt/llvm/lib"
    echo "Using x86_64 libclang: $LIBCLANG_PATH"
fi

# Kiểm tra flutter_rust_bridge_codegen
if ! command -v flutter_rust_bridge_codegen &> /dev/null; then
    echo "Cài flutter_rust_bridge_codegen..."
    cargo install flutter_rust_bridge_codegen --version 1.80.1 --features uuid
fi

# Kiểm tra file input
if [[ ! -f "src/flutter_ffi.rs" ]]; then
    echo "Lỗi: Không tìm thấy file src/flutter_ffi.rs"
    exit 1
fi

# Tạo thư mục output nếu chưa có
mkdir -p flutter/lib
mkdir -p flutter/macos/Runner

echo "Generating bridge code..."

# Chạy flutter_rust_bridge_codegen với môi trường đúng
flutter_rust_bridge_codegen \
    --rust-input ./src/flutter_ffi.rs \
    --dart-output ./flutter/lib/generated_bridge.dart \
    --c-output ./flutter/macos/Runner/bridge_generated.h

echo "✅ Generate bridge code thành công!"
echo "  - Dart: ./flutter/lib/generated_bridge.dart"
echo "  - C/H:  ./flutter/macos/Runner/bridge_generated.h" 