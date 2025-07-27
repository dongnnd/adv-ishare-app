# 🏗️ Android Architecture Guide: ARM64 vs ARM32 vs x86_64

## 📋 Table of Contents
- [Architecture Overview](#architecture-overview)
- [Technical Differences](#technical-differences)
- [Performance Comparison](#performance-comparison)
- [Market Share & Usage](#market-share--usage)
- [Build Considerations](#build-considerations)
- [Practical Examples](#practical-examples)

## 🔍 Architecture Overview

### ARM64 (aarch64, arm64-v8a)
- **Type**: 64-bit RISC architecture
- **Developer**: ARM Holdings
- **First Android**: Android 5.0 (API 21) - 2014
- **Current Standard**: ARMv8-A and newer

### ARM32 (armv7, armeabi-v7a)
- **Type**: 32-bit RISC architecture  
- **Developer**: ARM Holdings
- **First Android**: Android 1.6 (API 4) - 2009
- **Legacy Standard**: ARMv7-A

### x86_64 (x64, amd64)
- **Type**: 64-bit CISC architecture
- **Developer**: Intel/AMD
- **First Android**: Android 4.0 (API 14) - 2011
- **Primary Use**: Emulators, Chrome OS

## ⚙️ Technical Differences

### Register Architecture
```
ARM64:    31 × 64-bit general purpose registers (X0-X30)
ARM32:    15 × 32-bit general purpose registers (R0-R14)
x86_64:   16 × 64-bit general purpose registers (RAX-R15)
```

### Memory Addressing
```
ARM64:    Virtual: 48-bit, Physical: up to 48-bit
ARM32:    Virtual: 32-bit, Physical: up to 40-bit (LPAE)
x86_64:   Virtual: 48-bit, Physical: up to 52-bit
```

### Instruction Sets
```
ARM64:    AArch64 - Fixed 32-bit instructions
ARM32:    ARM/Thumb - Variable 16/32-bit instructions
x86_64:   x86-64 - Variable 1-15 byte instructions
```

## 📊 Performance Comparison

| Metric | ARM64 | ARM32 | x86_64 |
|--------|-------|-------|--------|
| **CPU Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Power Efficiency** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Memory Bandwidth** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **SIMD Performance** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Code Density** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

### Real-world Performance Examples
```bash
# Video decoding (1080p H.264)
ARM64:    ~2W power consumption, 60fps
ARM32:    ~1.5W power consumption, 30fps  
x86_64:   ~8W power consumption, 60fps

# Game rendering (complex 3D)
ARM64:    Mali-G78 ~900 GFLOPS
ARM32:    Mali-T880 ~200 GFLOPS
x86_64:   Intel Iris ~1000 GFLOPS
```

## 📱 Market Share & Usage (2024)

### Global Android Device Distribution
```
ARM64 (aarch64):     ~85%  📈 Growing
ARM32 (armv7):       ~12%  📉 Declining  
x86_64:              ~3%   ➡️  Stable (emulators)
```

### By Device Category
```
📱 Smartphones:
  - Premium:     100% ARM64
  - Mid-range:   95% ARM64, 5% ARM32
  - Budget:      70% ARM64, 30% ARM32

📟 Tablets:
  - Premium:     100% ARM64
  - Budget:      80% ARM64, 20% ARM32

💻 Emulators:
  - Development: 100% x86_64
  - Gaming:      100% x86_64
```

## 🛠️ Build Considerations

### Native Library Compilation

#### Cross-compilation Requirements
```bash
# ARM64 target
export CC=aarch64-linux-android21-clang
export CXX=aarch64-linux-android21-clang++
export AR=llvm-ar
export STRIP=llvm-strip

# ARM32 target  
export CC=armv7a-linux-androideabi21-clang
export CXX=armv7a-linux-androideabi21-clang++

# x86_64 target
export CC=x86_64-linux-android21-clang
export CXX=x86_64-linux-android21-clang++
```

#### Library Sizes (RustDesk example)
```
liblibrustdesk-aarch64.so:  ~25MB  (ARM64)
liblibrustdesk-armv7.so:    ~18MB  (ARM32)  
liblibrustdesk-x86_64.so:   ~28MB  (x86_64)
```

### APK Structure
```
app.apk
├── lib/
│   ├── arm64-v8a/        # ARM64 devices
│   │   └── librustdesk.so
│   ├── armeabi-v7a/      # ARM32 devices  
│   │   └── librustdesk.so
│   └── x86_64/           # x86_64 emulators
│       └── librustdesk.so
└── classes.dex
```

## 💡 Practical Examples

### Example 1: Video Streaming App
```kotlin
// Different optimizations per architecture
when (Build.SUPPORTED_ABIS[0]) {
    "arm64-v8a" -> {
        // Use hardware HEVC decoder
        // Enable 4K streaming
        useAdvancedCodecs = true
    }
    "armeabi-v7a" -> {
        // Fallback to software decoder
        // Limit to 1080p
        useAdvancedCodecs = false
    }
    "x86_64" -> {
        // Emulator - use software rendering
        useHardwareAcceleration = false
    }
}
```

### Example 2: Machine Learning
```kotlin
// TensorFlow Lite optimization
val interpreterOptions = Interpreter.Options().apply {
    when (Build.SUPPORTED_ABIS[0]) {
        "arm64-v8a" -> {
            // Use NNAPI delegate
            addDelegate(NnApiDelegate())
            setNumThreads(8) // Octa-core optimization
        }
        "armeabi-v7a" -> {
            // Use GPU delegate if available
            addDelegate(GpuDelegate())
            setNumThreads(4) // Quad-core limit
        }
        "x86_64" -> {
            // CPU only for emulator
            setNumThreads(4)
        }
    }
}
```

### Example 3: Build Script Selection
```bash
#!/bin/bash
# Smart architecture detection and building

detect_target_arch() {
    case "$1" in
        "aarch64"|"arm64"|"arm64-v8a")
            echo "aarch64-linux-android"
            ;;
        "armv7"|"arm"|"armeabi-v7a")  
            echo "armv7-linux-androideabi"
            ;;
        "x86_64"|"x64")
            echo "x86_64-linux-android"
            ;;
        *)
            echo "aarch64-linux-android" # Default to ARM64
            ;;
    esac
}

# Usage: ./build.sh arm64
TARGET_ARCH=$(detect_target_arch $1)
cargo ndk --target $TARGET_ARCH build --release
```

## 🎯 Recommendations

### For New Projects (2024+)
1. **Primary Target**: ARM64 (covers 85% of devices)
2. **Secondary Target**: ARM32 (for budget device support)  
3. **Development Target**: x86_64 (for emulator testing)

### For Performance-Critical Apps
```
Priority 1: ARM64 - Optimize heavily
Priority 2: ARM32 - Basic compatibility
Priority 3: x86_64 - Testing only
```

### For Broad Compatibility
```
Build order:
1. ARM64 (aarch64) - Modern devices
2. ARM32 (armv7) - Legacy support  
3. x86_64 - Emulator support
```

## 🔗 Useful Resources

- [Android NDK Architecture Guide](https://developer.android.com/ndk/guides/abis)
- [ARM Architecture Reference Manual](https://developer.arm.com/documentation/ddi0487/latest)
- [Intel x86_64 Developer Manual](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [Rust Cross-compilation Guide](https://rust-lang.github.io/rustup/cross-compilation.html)

---
*Generated for RustDesk Android library build project* 