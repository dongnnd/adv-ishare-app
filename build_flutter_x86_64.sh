#!/bin/bash

# Script để build Flutter app trong môi trường x86_64 (Rosetta)
# Sử dụng: ./build_flutter_x86_64.sh

set -e

# Đảm bảo chạy từ thư mục gốc của dự án
if [[ ! -f "Cargo.toml" ]]; then
    echo "Lỗi: Chạy script này từ thư mục gốc của dự án rustdesk"
    exit 1
fi

# Set môi trường cho x86_64
export LIBCLANG_PATH="/usr/local/opt/llvm/lib"
export DYLD_LIBRARY_PATH="/usr/local/opt/llvm/lib"

echo "🔧 Thiết lập môi trường cho x86_64 (Rosetta)..."
echo "LIBCLANG_PATH: $LIBCLANG_PATH"
echo "Architecture: $(arch -x86_64 uname -m)"

# Bước 1: Generate bridge code trong x86_64
echo ""
echo "📦 Bước 1: Generating bridge code trong x86_64..."
arch -x86_64 flutter_rust_bridge_codegen \
    --rust-input ./src/flutter_ffi.rs \
    --dart-output ./flutter/lib/generated_bridge.dart \
    --c-output ./flutter/macos/Runner/bridge_generated.h

# Bước 2: Build Flutter trong x86_64
echo ""
echo "🏗️  Bước 2: Building Flutter app trong x86_64..."
arch -x86_64 python3 ./build.py --flutter

echo ""
echo "✅ Build hoàn tất trong môi trường x86_64!" 