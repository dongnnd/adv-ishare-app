#!/usr/bin/env bash
#
# env_setup.sh  --  Thiết lập môi trường build RustDesk trên macOS Apple Silicon.
#
# Sử dụng:
#   source ./env_setup.sh             # Thiết lập PATH, LIBCLANG_PATH, alias tiện ích
#   source ./env_setup.sh --init      # (tuỳ chọn) Cài các phụ thuộc qua Homebrew & FVM trước
#   gen_bridge                        # Generate bridge (ffigen) sau khi source
#
# Biến môi trường bạn có thể override trước khi source:
#   FLUTTER_VERSION    (mặc định: 3.24.5)
#   FRB_VERSION        (mặc định: 1.80.1)  # flutter_rust_bridge_codegen
#   LLVM_PREFIX        (mặc định: $(brew --prefix llvm))
#   RUSTDESK_ROOT      (mặc định: thư mục chứa script)
#
set -euo pipefail

### ---------- Config mặc định ----------
FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
FRB_VERSION="${FRB_VERSION:-1.80.1}"
RUSTDESK_ROOT="${RUSTDESK_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Homebrew prefix (Apple Silicon thường là /opt/homebrew)
if command -v brew >/dev/null 2>&1; then
  LLVM_PREFIX="${LLVM_PREFIX:-$(brew --prefix llvm 2>/dev/null || true)}"
else
  LLVM_PREFIX="${LLVM_PREFIX:-/opt/homebrew/opt/llvm}"
fi

### ---------- Hàm tiện ích ----------
log() { printf "\033[1;32m[env_setup]\033[0m %s\n" "$*" >&2; }
warn() { printf "\033[1;33m[env_setup][warn]\033[0m %s\n" "$*" >&2; }
err() { printf "\033[1;31m[env_setup][err]\033[0m %s\n" "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

need_brew_pkg() {
  local pkg="$1"
  if ! brew list --versions "$pkg" >/dev/null 2>&1; then
    log "Cài $pkg..."
    brew install "$pkg"
  else
    log "$pkg đã có."
  fi
}

### ---------- --init: cài phụ thuộc ----------
if [[ "${1:-}" == "--init" ]]; then
  if ! have brew; then
    err "Không tìm thấy Homebrew. Cài tại https://brew.sh rồi chạy lại: source ./env_setup.sh --init"
    return 1 2>/dev/null || exit 1
  fi

  log "Cài đặt các gói cần thiết qua Homebrew..."
  need_brew_pkg llvm
  need_brew_pkg cmake
  need_brew_pkg ninja
  need_brew_pkg pkg-config
  need_brew_pkg automake || true
  need_brew_pkg autoconf || true

  # FVM để quản lý Flutter
  if ! brew list --versions fvm >/dev/null 2>&1; then
    log "Cài FVM..."
    brew tap leoafarias/fvm
    brew install fvm
  else
    log "FVM đã có."
  fi

  # Cocoapods (cần khi build iOS/macos Flutter)
  need_brew_pkg cocoapods

  log "Cài Flutter $FLUTTER_VERSION qua FVM (có thể mất thời gian)..."
  fvm install "$FLUTTER_VERSION" || true
  fvm use "$FLUTTER_VERSION" --global || true

  log "Cài flutter_rust_bridge_codegen qua cargo (version $FRB_VERSION)..."
  if have cargo; then
    cargo install flutter_rust_bridge_codegen --version "$FRB_VERSION" --locked || true
  else
    warn "Không tìm thấy cargo; hãy cài Rust toolchain (https://rustup.rs)."
  fi

  log "Khởi tạo xong (--init). Giờ hãy: source ./env_setup.sh (không --init) để load env."
  return 0 2>/dev/null || exit 0
fi

### ---------- Thiết lập PATH ----------
# Cargo
if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# FVM global Flutter
if have fvm; then
  # FVM global path thường ~/<user>/fvm/default/bin
  FVM_GLOBAL_BIN="$(fvm which flutter 2>/dev/null || true)"
  if [[ -n "$FVM_GLOBAL_BIN" ]]; then
    # Lấy thư mục bin
    FVM_BIN_DIR="$(dirname "$FVM_GLOBAL_BIN")"
    export PATH="$FVM_BIN_DIR:$PATH"
  fi
else
  warn "FVM chưa cài; dùng Flutter mặc định trong PATH."
fi

# LLVM toolchain
if [[ -d "$LLVM_PREFIX/bin" ]]; then
  export PATH="$LLVM_PREFIX/bin:$PATH"
else
  warn "Không tìm thấy LLVM_PREFIX ($LLVM_PREFIX/bin)."
fi

### ---------- LIBCLANG_PATH ----------
if [[ -d "$LLVM_PREFIX/lib" ]]; then
  export LIBCLANG_PATH="$LLVM_PREFIX/lib"
else
  warn "Không tìm thấy libclang trong $LLVM_PREFIX/lib; đặt LIBCLANG_PATH thủ công nếu cần."
fi

### ---------- Kiểm tra kiến trúc ----------
ARCH_EXPECTED="arm64"
ARCH_ACTUAL="$(uname -m)"
if [[ "$ARCH_ACTUAL" != "$ARCH_EXPECTED" ]]; then
  warn "Bạn đang chạy trên kiến trúc $ARCH_ACTUAL; máy M-series nên là arm64. Dùng: arch -arm64 bash -l"
fi

### ---------- Hàm generate bridge ----------
gen_bridge() {
  local rust_in="${1:-$RUSTDESK_ROOT/src/flutter_ffi.rs}"
  local dart_out="${2:-$RUSTDESK_ROOT/flutter/lib/generated_bridge.dart}"
  local c_out="${3:-$RUSTDESK_ROOT/flutter/macos/Runner/bridge_generated.h}"

  if [[ ! -f "$rust_in" ]]; then
    err "Không tìm thấy Rust input: $rust_in"
    return 1
  fi

  mkdir -p "$(dirname "$dart_out")" "$(dirname "$c_out")"

  log "Chạy flutter_rust_bridge_codegen..."
  # Đảm bảo chạy bằng arm64 (phòng khi shell x86_64)
  if [[ "$(uname -m)" != "arm64" ]]; then
    arch -arm64 flutter_rust_bridge_codegen \
      --rust-input "$rust_in" \
      --dart-output "$dart_out" \
      --c-output "$c_out"
  else
    flutter_rust_bridge_codegen \
      --rust-input "$rust_in" \
      --dart-output "$dart_out" \
      --c-output "$c_out"
  fi

  log "Generate xong:"
  log "  Dart: $dart_out"
  log "  C/H : $c_out"
}

export -f gen_bridge

### ---------- Tóm tắt ----------
log "Thiết lập môi trường hoàn tất."
log "  FLUTTER_VERSION = $FLUTTER_VERSION"
log "  FRB_VERSION     = $FRB_VERSION"
log "  LLVM_PREFIX     = $LLVM_PREFIX"
log "  LIBCLANG_PATH   = ${LIBCLANG_PATH:-<unset>}"
log "Dùng: gen_bridge  # hoặc gen_bridge <rust_in> <dart_out> <c_out>"

