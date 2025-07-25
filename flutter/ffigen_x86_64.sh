#!/bin/bash

# Wrapper script để chạy ffigen trong môi trường x86_64
# Sử dụng: ./ffigen_x86_64.sh [options]

set -e

# Set môi trường cho x86_64
export LIBCLANG_PATH="/usr/local/opt/llvm/lib"
export DYLD_LIBRARY_PATH="/usr/local/opt/llvm/lib"

echo "Running ffigen in x86_64 environment..."
echo "LIBCLANG_PATH: $LIBCLANG_PATH"

# Chạy ffigen trong môi trường x86_64
arch -x86_64 flutter pub run ffigen "$@" 