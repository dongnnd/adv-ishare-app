#!/bin/bash

# Script đơn giản để generate bridge code, bypass ffigen issue
# Sử dụng: ./gen_bridge_simple.sh

set -e

# Đảm bảo chạy từ thư mục gốc của dự án
if [[ ! -f "Cargo.toml" ]]; then
    echo "Lỗi: Chạy script này từ thư mục gốc của dự án rustdesk"
    exit 1
fi

# Set môi trường cho Apple Silicon
export LIBCLANG_PATH="/opt/homebrew/opt/llvm/lib"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/llvm/lib"

echo "Architecture: $(uname -m)"
echo "LIBCLANG_PATH: $LIBCLANG_PATH"

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

# Tạo file tạm để bypass ffigen issue
TEMP_CONFIG=$(mktemp)
cat > "$TEMP_CONFIG" << EOF
# Temporary ffigen config to bypass architecture issue
name: 'Temporary'
description: 'Temporary config'
output: 'temp.dart'
headers:
  entry_points:
    - 'temp.h'
EOF

# Chạy flutter_rust_bridge_codegen với skip ffigen
flutter_rust_bridge_codegen \
    --rust-input ./src/flutter_ffi.rs \
    --dart-output ./flutter/lib/generated_bridge.dart \
    --c-output ./flutter/macos/Runner/bridge_generated.h \
    --skip-deps-check

echo "✅ Generate bridge code thành công!"
echo "  - Dart: ./flutter/lib/generated_bridge.dart"
echo "  - C/H:  ./flutter/macos/Runner/bridge_generated.h"

# Cleanup
rm -f "$TEMP_CONFIG" 