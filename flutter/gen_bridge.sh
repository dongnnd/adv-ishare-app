#!/bin/bash

# Script để generate flutter_rust_bridge code trên Apple Silicon
# Sử dụng: ./gen_bridge.sh

set -e

# Đảm bảo chạy từ thư mục gốc của dự án
if [[ ! -f "Cargo.toml" ]]; then
    echo "Lỗi: Chạy script này từ thư mục gốc của dự án rustdesk"
    exit 1
fi

# Set môi trường cho Apple Silicon
export LIBCLANG_PATH="/opt/homebrew/opt/llvm/lib"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/llvm/lib"

# Kiểm tra kiến trúc
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
    echo "Cảnh báo: Bạn đang chạy trên kiến trúc $ARCH, nhưng máy Apple Silicon nên là arm64"
    echo "Để chạy đúng kiến trúc, dùng: arch -arm64 bash -l"
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
echo "LIBCLANG_PATH: $LIBCLANG_PATH"
echo "Architecture: $ARCH"

# Chạy flutter_rust_bridge_codegen với wrapper arm64
./flutter_rust_bridge_arm64.sh \
    --rust-input ./src/flutter_ffi.rs \
    --dart-output ./flutter/lib/generated_bridge.dart \
    --c-output ./flutter/macos/Runner/bridge_generated.h

echo "✅ Generate bridge code thành công!"
echo "  - Dart: ./flutter/lib/generated_bridge.dart"
echo "  - C/H:  ./flutter/macos/Runner/bridge_generated.h" 