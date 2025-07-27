#!/bin/bash

# RustDesk Android Build Environment Setup for macOS
# One-time setup script to prepare your development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_step "🚀 Setting up Android build environment for RustDesk on macOS"
echo

# Check macOS version
print_step "Checking macOS version..."
macos_version=$(sw_vers -productVersion)
print_status "macOS version: $macos_version"

# Install Homebrew if not exists
print_step "Checking Homebrew..."
if ! command_exists brew; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_status "Homebrew is installed: $(brew --version | head -n1)"
fi

# Update Homebrew
print_step "Updating Homebrew..."
brew update

# Install basic development tools
print_step "Installing development tools..."
brew install \
    cmake \
    ninja \
    nasm \
    wget \
    git \
    llvm \
    pkg-config \
    python3

# Install Rust
print_step "Installing Rust..."
if ! command_exists rustc; then
    print_warning "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
else
    print_status "Rust is already installed: $(rustc --version)"
fi

# Install specific Rust version
print_step "Installing Rust 1.75..."
rustup toolchain install 1.75
rustup default 1.75

# Install Android targets
print_step "Installing Rust Android targets..."
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android

# Install cargo tools
print_step "Installing cargo tools..."
cargo install cargo-ndk --version 3.1.2 --locked
cargo install flutter_rust_bridge_codegen --version 1.80.1 --features "uuid" --locked
cargo install cargo-expand --version 1.0.95 --locked

# Check Flutter
print_step "Checking Flutter..."
if ! command_exists flutter; then
    print_error "Flutter not found!"
    print_warning "Please install Flutter manually:"
    echo "  1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/macos"
    echo "  2. Extract to ~/development/flutter"
    echo "  3. Add to PATH: export PATH=\"\$PATH:\$HOME/development/flutter/bin\""
    echo "  4. Run: flutter doctor"
    echo
    print_warning "After installing Flutter, re-run this script or run the build script directly."
else
    flutter_version=$(flutter --version | head -n1 | cut -d' ' -f2)
    print_status "Flutter is installed: $flutter_version"
    
    # Check if correct version
    if [[ "$flutter_version" != "3.24.5" ]]; then
        print_warning "Flutter version $flutter_version detected, but 3.24.5 is recommended"
        print_warning "You may need to install Flutter 3.24.5 for best compatibility"
    fi
fi

# Setup Android SDK/NDK directories
print_step "Setting up Android SDK/NDK directories..."
mkdir -p ~/Library/Android/sdk/ndk
mkdir -p ~/Library/Android/sdk/cmdline-tools

# Setup vcpkg
print_step "Setting up vcpkg..."
if [ ! -d "$HOME/vcpkg" ]; then
    print_warning "Cloning vcpkg..."
    cd "$HOME"
    git clone https://github.com/Microsoft/vcpkg.git
    cd vcpkg
    git checkout "6f29f12e82a8293156836ad81cc9bf5af41fe836"
    ./bootstrap-vcpkg.sh
    cd - > /dev/null
else
    print_status "vcpkg already exists at $HOME/vcpkg"
fi

# Add environment variables to shell profile
print_step "Setting up environment variables..."
shell_profile=""
if [[ "$SHELL" == *"zsh"* ]]; then
    shell_profile="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    shell_profile="$HOME/.bash_profile"
fi

if [ -n "$shell_profile" ]; then
    print_status "Adding environment variables to $shell_profile"
    
    # Add environment variables if they don't exist
    grep -q "# RustDesk Android Build Environment" "$shell_profile" 2>/dev/null || cat >> "$shell_profile" << 'EOF'

# RustDesk Android Build Environment
export VCPKG_ROOT="$HOME/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/r27c"
export ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

# Add cargo to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi
EOF
    
    print_status "Environment variables added to $shell_profile"
    print_warning "Please run: source $shell_profile  (or restart your terminal)"
fi

# Create build configuration file
print_step "Creating build configuration..."
cat > "android_build_config.sh" << 'EOF'
#!/bin/bash
# RustDesk Android Build Configuration

# Environment Variables (matching GitHub Actions workflow)
export RUST_VERSION="1.75"
export CARGO_NDK_VERSION="3.1.2"
export LLVM_VERSION="15.0.6"
export FLUTTER_VERSION="3.24.5"
export ANDROID_FLUTTER_VERSION="3.24.5"
export VCPKG_COMMIT_ID="6f29f12e82a8293156836ad81cc9bf5af41fe836"
export VERSION="1.4.1"
export NDK_VERSION="r27c"

# Set paths
export VCPKG_ROOT="$HOME/vcpkg"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/$NDK_VERSION"
export ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"

# Add to PATH
export PATH="$VCPKG_ROOT:$PATH"
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

echo "✅ Android build environment loaded"
echo "📱 NDK Version: $NDK_VERSION"
echo "🦀 Rust Version: $RUST_VERSION"
echo "💙 Flutter Version: $FLUTTER_VERSION"
EOF

chmod +x android_build_config.sh

# Final instructions
echo
print_step "🎉 Setup completed!"
echo
print_status "Next steps:"
echo "  1. Restart your terminal or run: source $shell_profile"
echo "  2. Make sure Flutter is installed and in PATH"
echo "  3. Run the build script: ./build_android_lib_local.sh"
echo
print_status "Quick start commands:"
echo "  # Build all architectures"
echo "  ./build_android_lib_local.sh"
echo
echo "  # Build specific architecture"
echo "  ./build_android_lib_local.sh aarch64"
echo
echo "  # Load environment manually"
echo "  source android_build_config.sh"
echo
print_status "Verify installation:"
echo "  rustc --version        # Should show 1.75.x"
echo "  cargo --version        # Should be available"
echo "  flutter --version      # Should show Flutter version"
echo "  brew --version         # Should show Homebrew version"
echo

print_warning "If you encounter any issues:"
echo "  1. Make sure you're in the RustDesk project root directory"
echo "  2. Check that Flutter is properly installed"
echo "  3. Source your shell profile: source ~/.zshrc (or ~/.bash_profile)"
echo "  4. Run: ./build_android_lib_local.sh --help for usage info" 