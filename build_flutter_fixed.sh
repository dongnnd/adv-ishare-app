#!/bin/bash

# Script cuối cùng để build Flutter app với môi trường đúng
# Sử dụng: ./build_flutter_fixed.sh

set -e

# Đảm bảo chạy từ thư mục gốc của dự án
if [[ ! -f "Cargo.toml" ]]; then
    echo "Lỗi: Chạy script này từ thư mục gốc của dự án rustdesk"
    exit 1
fi

echo "🔧 Thiết lập môi trường cho Apple Silicon..."
echo "Architecture: $(uname -m)"

# Bước 1: Generate bridge code
echo ""
echo "📦 Bước 1: Generating bridge code..."
./flutter/gen_bridge_bypass.sh

# Bước 2: Build Flutter
echo ""
echo "🏗️  Bước 2: Building Flutter app..."
python3 ./build.py --flutter

echo ""
echo "✅ Build hoàn tất!"
echo ""
echo "📝 Tóm tắt:"
echo "  - Bridge code: ./flutter/lib/generated_bridge.dart"
echo "  - C headers:   ./flutter/macos/Runner/bridge_generated.h"
echo "  - Flutter app: ./flutter/build/" 