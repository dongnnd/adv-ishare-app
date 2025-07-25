#!/bin/bash

# Script để build Flutter app với môi trường đúng cho Apple Silicon
# Sử dụng: ./build_flutter.sh

set -e

# Đảm bảo chạy từ thư mục gốc của dự án
if [[ ! -f "Cargo.toml" ]]; then
    echo "Lỗi: Chạy script này từ thư mục gốc của dự án rustdesk"
    exit 1
fi

# Set môi trường cho Apple Silicon
export LIBCLANG_PATH="/opt/homebrew/opt/llvm/lib"
export DYLD_LIBRARY_PATH="/opt/homebrew/opt/llvm/lib"

echo "🔧 Thiết lập môi trường cho Apple Silicon..."
echo "LIBCLANG_PATH: $LIBCLANG_PATH"
echo "Architecture: $(uname -m)"

# Bước 1: Generate bridge code
echo ""
echo "📦 Bước 1: Generating bridge code..."
./flutter/gen_bridge.sh

# Bước 2: Build Flutter
echo ""
echo "🏗️  Bước 2: Building Flutter app..."
python3 ./build.py --flutter

echo ""
echo "✅ Build hoàn tất!" 