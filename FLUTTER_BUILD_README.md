# Flutter Build Scripts cho Apple Silicon

## Vấn đề gốc

Khi chạy lệnh generate bridge code trên máy Apple Silicon (M1/M2), bạn gặp lỗi:
```
Invalid argument(s): Failed to load dynamic library '/opt/homebrew/opt/llvm/lib/libclang.dylib': dlopen(/opt/homebrew/opt/llvm/lib/libclang.dylib, 0x0001): tried: '/opt/homebrew/opt/llvm/lib/libclang.dylib' (mach-o file, but is an incompatible architecture (have 'arm64', need 'x86_64'))
```

## Nguyên nhân

- `flutter_rust_bridge_codegen` chạy trong môi trường arm64
- Nhưng `ffigen` (tool Dart để parse C headers) lại chạy trong môi trường x86_64
- Dẫn đến conflict kiến trúc với libclang

## Giải pháp

Đã tạo các script để bypass vấn đề này:

### 1. Script chính (Khuyến nghị sử dụng)

```bash
./build_flutter_fixed.sh
```

Script này sẽ:
- Generate bridge code với môi trường đúng
- Build Flutter app
- Tự động set các biến môi trường cần thiết

### 2. Script chỉ generate bridge code

```bash
./flutter/gen_bridge_bypass.sh
```

### 3. Script build trong môi trường x86_64 (nếu cần)

```bash
./build_flutter_x86_64.sh
```

## Các file đã tạo

- `build_flutter_fixed.sh` - Script chính để build hoàn chỉnh
- `flutter/gen_bridge_bypass.sh` - Script generate bridge code
- `flutter/gen_bridge.sh` - Script cũ (có thể gặp lỗi)
- `build_flutter_x86_64.sh` - Script build trong x86_64
- `flutter_rust_bridge_arm64.sh` - Wrapper cho flutter_rust_bridge_codegen
- `flutter/flutter_arm64.sh` - Wrapper cho flutter arm64
- `flutter/ffigen_x86_64.sh` - Wrapper cho ffigen x86_64

## Cách sử dụng

1. **Chạy script chính:**
   ```bash
   ./build_flutter_fixed.sh
   ```

2. **Hoặc chạy từng bước:**
   ```bash
   # Bước 1: Generate bridge code
   ./flutter/gen_bridge_bypass.sh
   
   # Bước 2: Build Flutter
   python3 ./build.py --flutter
   ```

## Kết quả

Sau khi chạy thành công, bạn sẽ có:
- `./flutter/lib/generated_bridge.dart` - Bridge code Dart
- `./flutter/macos/Runner/bridge_generated.h` - C headers
- `./flutter/build/` - Flutter app đã build

## Lưu ý

- Script sẽ tự động set `LIBCLANG_PATH` và `DYLD_LIBRARY_PATH`
- Có thể có warning về nullability, nhưng không ảnh hưởng đến kết quả
- Đảm bảo chạy từ thư mục gốc của dự án rustdesk 