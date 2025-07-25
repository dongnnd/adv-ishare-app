#!/bin/bash

# Wrapper script để force Flutter chạy trong arm64
# Sử dụng: ./flutter_arm64.sh pub run ffigen ...

set -e

# Force chạy trong arm64
exec arch -arm64 flutter "$@" 