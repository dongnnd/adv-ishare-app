#!/bin/bash

# Quick Build Script for RustDesk Android Libraries
# This script provides an easy way to get started with building

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║    🤖 RustDesk Android Library Builder for macOS        ║"
    echo "║                                                          ║"
    echo "║    Quick setup and build script                          ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC}  $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_step() {
    echo -e "${BLUE}🔄${NC} $1"
}

check_requirements() {
    print_step "Checking basic requirements..."
    
    # Check if we're in the right directory
    if [ ! -f "Cargo.toml" ] || [ ! -d "src" ] || [ ! -d "flutter" ]; then
        print_error "Please run this script from the RustDesk project root directory"
        echo "Expected files/directories: Cargo.toml, src/, flutter/"
        exit 1
    fi
    
    # Check macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    
    print_status "Basic requirements check passed"
}

show_options() {
    echo -e "${BLUE}Choose an option:${NC}"
    echo "1) 🚀 Full setup + build all architectures (recommended for first time)"
    echo "2) 🏗️  Build all architectures (if already set up)"
    echo "3) 📱 Build ARM64 only (fastest, covers most devices)"
    echo "4) 🔧 Setup environment only"
    echo "5) 📋 Show help and exit"
    echo "6) 🐛 Debug environment"
    echo
    read -p "Enter your choice (1-6): " choice
    echo
}

run_setup() {
    print_step "Running environment setup..."
    
    if [ ! -f "setup_android_build_env.sh" ]; then
        print_error "setup_android_build_env.sh not found!"
        exit 1
    fi
    
    chmod +x setup_android_build_env.sh
    ./setup_android_build_env.sh
    
    print_status "Setup completed!"
    print_warning "Please restart your terminal or run: source ~/.zshrc"
    echo
    read -p "Press Enter after restarting terminal to continue..."
}

run_build() {
    local arch=$1
    print_step "Building libraries for: ${arch:-all architectures}"
    
    if [ ! -f "build_android_lib_local.sh" ]; then
        print_error "build_android_lib_local.sh not found!"
        exit 1
    fi
    
    chmod +x build_android_lib_local.sh
    ./build_android_lib_local.sh $arch
}

show_help() {
    echo -e "${BLUE}📚 RustDesk Android Library Builder Help${NC}"
    echo
    echo "This script helps you build liblibrustdesk.so for Android on macOS."
    echo
    echo -e "${GREEN}Manual Commands:${NC}"
    echo "  ./setup_android_build_env.sh              - One-time setup"
    echo "  ./build_android_lib_local.sh              - Build all architectures"
    echo "  ./build_android_lib_local.sh aarch64      - Build ARM64 only"
    echo "  make -f Makefile.android help             - Show Makefile options"
    echo
    echo -e "${GREEN}Files Created:${NC}"
    echo "  android-libs/                             - Output directory"
    echo "  android_build_config.sh                   - Environment config"
    echo "  README_Android_Build.md                   - Detailed documentation"
    echo
    echo -e "${GREEN}Requirements:${NC}"
    echo "  - macOS 10.15+"
    echo "  - ~10GB disk space"
    echo "  - Internet connection"
    echo "  - Flutter 3.24.5 (manual install required)"
    echo
    echo -e "${GREEN}Output:${NC}"
    echo "  - liblibrustdesk-aarch64.so               - ARM64 library"
    echo "  - liblibrustdesk-armv7.so                 - ARMv7 library"
    echo "  - liblibrustdesk-x86_64.so                - x86_64 library"
    echo
}

debug_environment() {
    print_step "Environment Debug Information"
    echo
    echo "Current directory: $(pwd)"
    echo "macOS version: $(sw_vers -productVersion)"
    echo "Shell: $SHELL"
    echo
    echo "Rust: $(rustc --version 2>/dev/null || echo 'Not found')"
    echo "Cargo: $(cargo --version 2>/dev/null || echo 'Not found')"
    echo "Flutter: $(flutter --version 2>/dev/null | head -n1 || echo 'Not found')"
    echo "Homebrew: $(brew --version 2>/dev/null | head -n1 || echo 'Not found')"
    echo
    echo "cargo-ndk: $(cargo-ndk --version 2>/dev/null || echo 'Not found')"
    echo "flutter_rust_bridge_codegen: $(flutter_rust_bridge_codegen --version 2>/dev/null || echo 'Not found')"
    echo
    echo "vcpkg: $(test -d "$HOME/vcpkg" && echo 'Found' || echo 'Not found')"
    echo "Android NDK: $(test -d "$HOME/Library/Android/sdk/ndk/r27c" && echo 'Found' || echo 'Not found')"
    echo
    echo "Environment variables:"
    echo "  ANDROID_NDK_HOME: ${ANDROID_NDK_HOME:-'Not set'}"
    echo "  VCPKG_ROOT: ${VCPKG_ROOT:-'Not set'}"
    echo
    echo "Files check:"
    echo "  Cargo.toml: $(test -f 'Cargo.toml' && echo 'Found' || echo 'Not found')"
    echo "  src/ directory: $(test -d 'src' && echo 'Found' || echo 'Not found')"
    echo "  flutter/ directory: $(test -d 'flutter' && echo 'Found' || echo 'Not found')"
    echo "  setup script: $(test -f 'setup_android_build_env.sh' && echo 'Found' || echo 'Not found')"
    echo "  build script: $(test -f 'build_android_lib_local.sh' && echo 'Found' || echo 'Not found')"
    echo
}

main() {
    print_banner
    check_requirements
    show_options
    
    case $choice in
        1)
            print_step "Option 1: Full setup + build all"
            run_setup
            run_build
            ;;
        2)
            print_step "Option 2: Build all architectures"
            run_build
            ;;
        3)
            print_step "Option 3: Build ARM64 only"
            run_build "aarch64"
            ;;
        4)
            print_step "Option 4: Setup environment only"
            run_setup
            ;;
        5)
            show_help
            exit 0
            ;;
        6)
            debug_environment
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac
    
    echo
    print_status "Task completed!"
    
    if [ -d "android-libs" ]; then
        echo
        print_status "Built libraries:"
        ls -la android-libs/
        echo
        print_status "Libraries are ready in the android-libs/ directory!"
    fi
    
    echo
    print_status "For more options, see:"
    echo "  📖 README_Android_Build.md - Detailed documentation"
    echo "  🛠️  make -f Makefile.android help - Makefile commands"
    echo "  🔧 ./build_android_lib_local.sh --help - Script help"
}

# Run main function
main "$@" 