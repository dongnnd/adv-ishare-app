#!/bin/bash

# Script để bypass ffigen issue bằng cách tạo file tạm
# Sử dụng: ./gen_bridge_bypass.sh

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

# Tạo file ffigen config tạm để bypass
FFIGEN_CONFIG=$(mktemp)
cat > "$FFIGEN_CONFIG" << 'EOF'
name: 'Temporary'
description: 'Temporary config to bypass architecture issue'
output: 'temp.dart'
headers:
  entry_points:
    - 'temp.h'
  compiler_opts: []
EOF

# Tạo file tạm để ffigen không bị lỗi
TEMP_HEADER=$(mktemp)
cat > "$TEMP_HEADER" << 'EOF'
// Temporary header file
void temp_function() {}
EOF

# Export biến môi trường để ffigen sử dụng
export FFIGEN_CONFIG_PATH="$FFIGEN_CONFIG"

# Chạy flutter_rust_bridge_codegen với environment variables
LIBCLANG_PATH="/usr/local/opt/llvm/lib" \
DYLD_LIBRARY_PATH="/usr/local/opt/llvm/lib" \
flutter_rust_bridge_codegen \
    --rust-input ./src/flutter_ffi.rs \
    --dart-output ./flutter/lib/generated_bridge.dart \
    --c-output ./flutter/macos/Runner/bridge_generated.h

echo "✅ Generate bridge code thành công!"
echo "  - Dart: ./flutter/lib/generated_bridge.dart"
echo "  - C/H:  ./flutter/macos/Runner/bridge_generated.h"

# Cleanup
rm -f "$FFIGEN_CONFIG" "$TEMP_HEADER" 