#!/bin/bash

# RustDesk Android Library Local Build Script for macOS
# Based on GitHub Actions workflow but adapted for local development

set -e

# Environment Variables (matching workflow)
export RUST_VERSION="1.75"
export CARGO_NDK_VERSION="3.1.2"
export LLVM_VERSION="15.0.6"
export FLUTTER_VERSION="3.24.5"
export ANDROID_FLUTTER_VERSION="3.24.5"
export VCPKG_COMMIT_ID="6f29f12e82a8293156836ad81cc9bf5af41fe836"
export VERSION="1.4.1"
export NDK_VERSION="r27c"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check and install dependencies
check_dependencies() {
    print_step "Checking dependencies..."
    
    # Check Homebrew
    if ! command_exists brew; then
        print_error "Homebrew not found. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # Check and install basic tools
    local tools=("cmake" "ninja" "nasm" "wget" "git")
    for tool in "${tools[@]}"; do
        if ! command_exists "$tool"; then
            print_warning "$tool not found. Installing via Homebrew..."
            brew install "$tool"
        else
            print_status "$tool is installed"
        fi
    done
    
    # Check Rust
    if ! command_exists rustc; then
        print_error "Rust not found. Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    fi
    
    # Check current Rust version and install correct version
    local current_rust_version=$(rustc --version | cut -d' ' -f2)
    print_status "Current Rust version: $current_rust_version"
    print_status "Required Rust version: $RUST_VERSION"
    
    rustup toolchain install "$RUST_VERSION"
    rustup default "$RUST_VERSION"
    
    # Check Flutter
    if ! command_exists flutter; then
        print_error "Flutter not found. Please install Flutter $FLUTTER_VERSION manually:"
        echo "  https://docs.flutter.dev/get-started/install/macos"
        exit 1
    fi
    
    local current_flutter_version=$(flutter --version | head -n1 | cut -d' ' -f2)
    print_status "Current Flutter version: $current_flutter_version"
    print_status "Required Flutter version: $FLUTTER_VERSION"
}

# Function to setup Android NDK
setup_android_ndk() {
    print_step "Setting up Android NDK..."
    
    local ndk_dir="$HOME/Library/Android/sdk/ndk"
    local ndk_path="$ndk_dir/$NDK_VERSION"
    
    if [ ! -d "$ndk_path" ]; then
        print_warning "Android NDK $NDK_VERSION not found. Downloading..."
        mkdir -p "$ndk_dir"
        cd "$ndk_dir"
        
        # Download NDK
        local ndk_url="https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-darwin.zip"
        wget -O "android-ndk-${NDK_VERSION}-darwin.zip" "$ndk_url"
        unzip "android-ndk-${NDK_VERSION}-darwin.zip"
        mv "android-ndk-${NDK_VERSION}" "$NDK_VERSION"
        rm "android-ndk-${NDK_VERSION}-darwin.zip"
        cd - > /dev/null
    fi
    
    export ANDROID_NDK_HOME="$ndk_path"
    export ANDROID_NDK_ROOT="$ndk_path"
    export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"
    
    print_status "Android NDK setup completed: $ANDROID_NDK_HOME"
}

# Function to setup vcpkg
setup_vcpkg() {
    print_step "Setting up vcpkg..."
    
    local vcpkg_dir="$HOME/vcpkg"
    
    if [ ! -d "$vcpkg_dir" ]; then
        print_warning "vcpkg not found. Cloning..."
        cd "$HOME"
        git clone https://github.com/Microsoft/vcpkg.git
        cd vcpkg
        git checkout "$VCPKG_COMMIT_ID"
        ./bootstrap-vcpkg.sh
        cd - > /dev/null
    else
        print_status "vcpkg found at $vcpkg_dir"
        cd "$vcpkg_dir"
        git fetch
        git checkout "$VCPKG_COMMIT_ID"
        cd - > /dev/null
    fi
    
    export VCPKG_ROOT="$vcpkg_dir"
    export PATH="$VCPKG_ROOT:$PATH"
    
    print_status "vcpkg setup completed: $VCPKG_ROOT"
}

# Function to install Rust Android targets and cargo-ndk
setup_rust_android() {
    print_step "Setting up Rust for Android..."
    
    # Install Android targets
    rustup target add aarch64-linux-android
    rustup target add armv7-linux-androideabi  
    rustup target add x86_64-linux-android
    rustup target add i686-linux-android
    
    # Install cargo-ndk
    if ! command_exists cargo-ndk; then
        print_warning "cargo-ndk not found. Installing..."
        cargo install cargo-ndk --version "$CARGO_NDK_VERSION" --locked
    else
        print_status "cargo-ndk is installed"
    fi
    
    # Install flutter_rust_bridge_codegen
    if ! command_exists flutter_rust_bridge_codegen; then
        print_warning "flutter_rust_bridge_codegen not found. Installing..."
        cargo install flutter_rust_bridge_codegen --version "1.80.1" --features "uuid" --locked
        cargo install cargo-expand --version "1.0.95" --locked
    else
        print_status "flutter_rust_bridge_codegen is installed"
    fi
}

# Function to generate bridge
generate_bridge() {
    print_step "Generating Flutter-Rust bridge..."
    
    # Setup Flutter dependencies
    cd flutter
    sed -i '' 's/extended_text: 14.0.0/extended_text: 13.0.0/g' pubspec.yaml 2>/dev/null || true
    flutter pub get
    cd ..
    
    # Generate bridge
    flutter_rust_bridge_codegen \
        --rust-input ./src/flutter_ffi.rs \
        --dart-output ./flutter/lib/generated_bridge.dart \
        --c-output ./flutter/macos/Runner/bridge_generated.h \
        --class-name Rustdesk
    
    cp ./flutter/macos/Runner/bridge_generated.h ./flutter/ios/Runner/bridge_generated.h
    
    print_status "Bridge generation completed"
}

# Function to install vcpkg dependencies for Android
install_vcpkg_android_deps() {
    local android_abi=$1
    print_step "Installing vcpkg dependencies for $android_abi..."
    
    # Map Android ABI to vcpkg triplet
    local vcpkg_triplet
    case $android_abi in
        "arm64-v8a")
            vcpkg_triplet="arm64-android"
            ;;
        "armeabi-v7a")
            vcpkg_triplet="arm-neon-android"
            ;;
        "x86_64")
            vcpkg_triplet="x64-android"
            ;;
        "x86")
            vcpkg_triplet="x86-android"
            ;;
        *)
            print_error "Unknown Android ABI: $android_abi"
            exit 1
            ;;
    esac
    
    cd flutter
    ./build_android_deps.sh "$android_abi"
    cd ..
    
    print_status "vcpkg dependencies installed for $android_abi"
}

# Function to build library for specific architecture
build_lib() {
    local arch=$1
    local target=$2
    local android_abi=$3
    
    print_step "Building library for $arch ($target)..."
    
    # Install dependencies for this architecture
    install_vcpkg_android_deps "$android_abi"
    
    # Add target
    rustup target add "$target"
    
    # Build
    case $target in
        "aarch64-linux-android")
            ./flutter/ndk_arm64.sh
            ;;
        "armv7-linux-androideabi")
            ./flutter/ndk_arm.sh
            ;;
        "x86_64-linux-android")
            ./flutter/ndk_x64.sh
            ;;
        "i686-linux-android")
            ./flutter/ndk_x86.sh
            ;;
        *)
            print_error "Unknown target: $target"
            exit 1
            ;;
    esac
    
    # Verify build
    local lib_path="./target/$target/release/liblibrustdesk.so"
    if [ -f "$lib_path" ]; then
        print_status "Successfully built: $lib_path"
        ls -lh "$lib_path"
        file "$lib_path"
    else
        print_error "Failed to build library for $target"
        exit 1
    fi
}

# Function to organize output
organize_output() {
    print_step "Organizing output libraries..."
    
    local output_dir="./android-libs"
    mkdir -p "$output_dir"
    
    # Copy libraries with descriptive names
    local targets=("aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android")
    local archs=("aarch64" "armv7" "x86_64")
    
    for i in "${!targets[@]}"; do
        local target="${targets[$i]}"
        local arch="${archs[$i]}"
        local lib_path="./target/$target/release/liblibrustdesk.so"
        
        if [ -f "$lib_path" ]; then
            cp "$lib_path" "$output_dir/liblibrustdesk-$arch.so"
            print_status "Copied: $output_dir/liblibrustdesk-$arch.so"
        fi
    done
    
    # Create README
    cat > "$output_dir/README.md" << EOF
# RustDesk Android Libraries - Version $VERSION

Built on: $(date)
Built on macOS: $(sw_vers -productVersion)
Rust version: $(rustc --version)
NDK version: $NDK_VERSION

## Libraries:
EOF
    
    for lib in "$output_dir"/*.so; do
        if [ -f "$lib" ]; then
            echo "- $(basename "$lib"): $(du -h "$lib" | cut -f1)" >> "$output_dir/README.md"
        fi
    done
    
    print_status "Output organized in: $output_dir"
    ls -la "$output_dir"
}

# Main build function
main() {
    local build_arch="${1:-all}"
    
    print_status "Starting RustDesk Android library build..."
    print_status "Build architecture: $build_arch"
    print_status "Working directory: $(pwd)"
    
    # Check if we're in the right directory
    if [ ! -f "Cargo.toml" ] || [ ! -d "src" ] || [ ! -d "flutter" ]; then
        print_error "Please run this script from the RustDesk project root directory"
        exit 1
    fi
    
    # Setup steps
    check_dependencies
    setup_android_ndk
    setup_vcpkg
    setup_rust_android
    generate_bridge
    
    # Build libraries
    case $build_arch in
        "all")
            build_lib "aarch64" "aarch64-linux-android" "arm64-v8a"
            build_lib "armv7" "armv7-linux-androideabi" "armeabi-v7a"
            build_lib "x86_64" "x86_64-linux-android" "x86_64"
            ;;
        "aarch64")
            build_lib "aarch64" "aarch64-linux-android" "arm64-v8a"
            ;;
        "armv7")
            build_lib "armv7" "armv7-linux-androideabi" "armeabi-v7a"
            ;;
        "x86_64")
            build_lib "x86_64" "x86_64-linux-android" "x86_64"
            ;;
        *)
            print_error "Unknown architecture: $build_arch"
            echo "Usage: $0 [all|aarch64|armv7|x86_64]"
            exit 1
            ;;
    esac
    
    organize_output
    
    print_status "Build completed successfully!"
}

# Show usage if requested
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "RustDesk Android Library Builder for macOS"
    echo ""
    echo "Usage: $0 [architecture]"
    echo ""
    echo "Arguments:"
    echo "  all      Build for all architectures (default)"
    echo "  aarch64  Build for ARM64 only"
    echo "  armv7    Build for ARMv7 only"
    echo "  x86_64   Build for x86_64 only"
    echo ""
    echo "Environment Variables:"
    echo "  RUST_VERSION=$RUST_VERSION"
    echo "  NDK_VERSION=$NDK_VERSION"
    echo "  FLUTTER_VERSION=$FLUTTER_VERSION"
    echo ""
    exit 0
fi

# Run main function
main "$@" 