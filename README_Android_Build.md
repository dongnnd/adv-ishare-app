# 🤖 RustDesk Android Library Build Guide for macOS

Complete guide to build `liblibrustdesk.so` for Android on your local macOS machine.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Prerequisites](#-prerequisites)
- [One-time Setup](#-one-time-setup)
- [Building Libraries](#-building-libraries)
- [Using Makefile](#-using-makefile)
- [Troubleshooting](#-troubleshooting)
- [Architecture Support](#-architecture-support)
- [Output Structure](#-output-structure)

## 🚀 Quick Start

### Option 1: Using Scripts (Recommended)

1. **Run one-time setup:**
   ```bash
   chmod +x setup_android_build_env.sh
   ./setup_android_build_env.sh
   ```

2. **Restart terminal or source your shell profile:**
   ```bash
   source ~/.zshrc  # or ~/.bash_profile
   ```

3. **Install Flutter manually** (if not already installed):
   - Download from: https://docs.flutter.dev/get-started/install/macos
   - Extract to `~/development/flutter`
   - Add to PATH: `export PATH="$PATH:$HOME/development/flutter/bin"`

4. **Build libraries:**
   ```bash
   ./build_android_lib_local.sh
   ```

### Option 2: Using Makefile

1. **Setup environment:**
   ```bash
   make -f Makefile.android setup
   ```

2. **Build all architectures:**
   ```bash
   make -f Makefile.android build-all
   ```

3. **View available commands:**
   ```bash
   make -f Makefile.android help
   ```

## 📋 Prerequisites

### System Requirements
- **macOS**: 10.15 (Catalina) or later
- **Xcode Command Line Tools**: `xcode-select --install`
- **Homebrew**: Package manager for macOS
- **Disk Space**: ~10GB for all dependencies and builds

### Required Software
- **Rust** 1.75 (automatically installed)
- **Flutter** 3.24.5 (manual installation required)
- **Android NDK** r27c (automatically downloaded)
- **vcpkg** (automatically cloned and built)

## 🔧 One-time Setup

### Automatic Setup (Recommended)

The setup script will install and configure everything for you:

```bash
chmod +x setup_android_build_env.sh
./setup_android_build_env.sh
```

**What it does:**
- ✅ Installs Homebrew (if needed)
- ✅ Installs development tools (cmake, ninja, nasm, etc.)
- ✅ Installs Rust 1.75 and Android targets
- ✅ Installs cargo tools (cargo-ndk, flutter_rust_bridge_codegen)
- ✅ Downloads and configures Android NDK r27c
- ✅ Clones and builds vcpkg with correct commit
- ✅ Sets up environment variables
- ⚠️ **Flutter must be installed manually**

### Manual Flutter Installation

1. **Download Flutter SDK:**
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.5-stable.zip
   unzip flutter_macos_3.24.5-stable.zip
   ```

2. **Add to PATH:**
   ```bash
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Verify installation:**
   ```bash
   flutter doctor
   flutter --version
   ```

## 🏗️ Building Libraries

### Build All Architectures

```bash
./build_android_lib_local.sh
```

This builds libraries for:
- ARM64 (aarch64) - Most modern Android devices
- ARMv7 - Older Android devices 
- x86_64 - Android emulators

### Build Specific Architecture

```bash
# ARM64 only (recommended for most use cases)
./build_android_lib_local.sh aarch64

# ARMv7 only
./build_android_lib_local.sh armv7

# x86_64 only (for emulators)
./build_android_lib_local.sh x86_64
```

### Check Build Status

Monitor the build process:
- ✅ Green messages: Successful steps
- ⚠️ Yellow messages: Warnings (usually OK)
- ❌ Red messages: Errors (need attention)

## 🛠️ Using Makefile

The Makefile provides convenient shortcuts:

### Common Commands

```bash
# Show all available commands
make -f Makefile.android help

# One-time setup
make -f Makefile.android setup

# Check if environment is properly configured
make -f Makefile.android check-env

# Build all architectures
make -f Makefile.android build-all

# Build specific architectures
make -f Makefile.android build-aarch64
make -f Makefile.android build-armv7
make -f Makefile.android build-x86_64

# Clean build artifacts
make -f Makefile.android clean

# Deep clean (including cargo cache)
make -f Makefile.android clean-all
```

### Development Shortcuts

```bash
# Quick setup for development
make -f Makefile.android dev-setup

# Quick build (bridge + ARM64)
make -f Makefile.android dev-build

# Generate Flutter-Rust bridge only
make -f Makefile.android flutter-bridge

# Show built libraries
make -f Makefile.android show-libs

# Debug environment issues
make -f Makefile.android debug-env
```

## 🎯 Architecture Support

| Architecture | Target Triple | Android ABI | Use Case |
|-------------|---------------|-------------|----------|
| **ARM64** | `aarch64-linux-android` | `arm64-v8a` | Modern Android devices (recommended) |
| **ARMv7** | `armv7-linux-androideabi` | `armeabi-v7a` | Older Android devices |
| **x86_64** | `x86_64-linux-android` | `x86_64` | Android emulators |

### Recommended Build Strategy

1. **Start with ARM64** - Covers 95%+ of modern devices
2. **Add ARMv7** - If you need to support older devices
3. **Add x86_64** - Only if you need emulator support

## 📁 Output Structure

After building, libraries are organized in the `android-libs/` directory:

```
android-libs/
├── liblibrustdesk-aarch64.so  # ARM64 library
├── liblibrustdesk-armv7.so    # ARMv7 library
├── liblibrustdesk-x86_64.so   # x86_64 library
└── README.md                   # Build information
```

### Library Information

Each library contains:
- **Build timestamp**
- **Architecture details**
- **File size**
- **Rust/NDK versions used**

### Using in Android Projects

Copy the appropriate library to your Android project:

```
android_project/
└── app/
    └── src/
        └── main/
            └── jniLibs/
                ├── arm64-v8a/
                │   └── librustdesk.so      # from liblibrustdesk-aarch64.so
                ├── armeabi-v7a/
                │   └── librustdesk.so      # from liblibrustdesk-armv7.so
                └── x86_64/
                    └── librustdesk.so      # from liblibrustdesk-x86_64.so
```

## 🐛 Troubleshooting

### Common Issues

#### 1. "Flutter not found"
```bash
# Check if Flutter is in PATH
flutter --version

# If not found, add to PATH
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

#### 2. "Android NDK not found"
```bash
# The script should download NDK automatically, but if it fails:
# Check if directory exists
ls -la ~/Library/Android/sdk/ndk/r27c

# If not, run setup again
./setup_android_build_env.sh
```

#### 3. "cargo-ndk not found"
```bash
# Reinstall cargo-ndk
cargo install cargo-ndk --version 3.1.2 --locked --force
```

#### 4. "vcpkg build failed"
```bash
# Clean and rebuild vcpkg
rm -rf ~/vcpkg
./setup_android_build_env.sh
```

#### 5. Rust version mismatch
```bash
# Check current version
rustc --version

# Install and set correct version
rustup toolchain install 1.75
rustup default 1.75
```

### Debug Environment

Check your environment setup:

```bash
# Using Makefile
make -f Makefile.android debug-env

# Manual check
rustc --version
cargo --version
flutter --version
cargo-ndk --version
echo $ANDROID_NDK_HOME
echo $VCPKG_ROOT
```

### Clean and Retry

If builds fail, try cleaning:

```bash
# Clean build artifacts
make -f Makefile.android clean

# Deep clean (more thorough)
make -f Makefile.android clean-all

# Then rebuild
make -f Makefile.android build-all
```

### Getting Help

1. **Check logs** - Build script shows detailed error messages
2. **Verify environment** - Run `make -f Makefile.android check-env`
3. **Clean and retry** - Often fixes temporary issues
4. **Check disk space** - Ensure you have enough free space (10GB+)

## 📊 Build Times

Typical build times on M1/M2 MacBook Pro:

- **First build** (all deps): 30-60 minutes
- **Subsequent builds**: 10-20 minutes
- **Single architecture**: 5-10 minutes
- **Bridge generation only**: 1-2 minutes

## 🚀 Tips for Faster Builds

1. **Use specific architecture** - Build only what you need
2. **Clean selectively** - Use `make clean` instead of `make clean-all`
3. **Parallel builds** - The script automatically uses multiple cores
4. **SSD recommended** - Significantly faster than HDD
5. **Close other apps** - Free up RAM for build process

## 📝 Environment Variables Reference

Key environment variables set by the build system:

```bash
RUST_VERSION="1.75"
CARGO_NDK_VERSION="3.1.2"
FLUTTER_VERSION="3.24.5"
NDK_VERSION="r27c"
VCPKG_COMMIT_ID="6f29f12e82a8293156836ad81cc9bf5af41fe836"
VERSION="1.4.1"

ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk/r27c"
ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
VCPKG_ROOT="$HOME/vcpkg"
```

## 🎉 Success!

Once you see "Build completed successfully!", your libraries are ready in the `android-libs/` directory. You can now integrate them into your Android projects!

---

**Need help?** Check the troubleshooting section or review the build logs for specific error messages. 