# Result Channel

A Flutter plugin infrastructure that provides a simplified abstraction layer for other plugins to implement FFI (Foreign Function Interface) native calls. Think of it as a "Dart Native Interop" helper.

## Overview

**Result Channel** is not an end-user plugin, but rather a **foundation library** designed to help plugin developers create high-performance native bridges using FFI. It abstracts the complexity of FFI implementation, providing a clean, type-safe interface for calling native functions from Dart.

## Purpose

This plugin serves as:

-   **Infrastructure Layer**: Foundation for other plugins to build upon
-   **FFI Abstraction**: Simplifies the complexity of direct FFI calls
-   **Type Safety**: Provides strongly-typed interfaces between Dart and native code
-   **Performance Optimization**: Enables synchronous, high-performance native calls
-   **Cross-Platform Bridge**: Unified interface for Android and iOS native interop

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│                    Your Plugin                              │
├─────────────────────────────────────────────────────────────┤
│                   Result Channel                            │
│                (FFI Abstraction Layer)                      │
├─────────────────────────────────────────────────────────────┤
│              Native Libraries (C/C++)                       │
│                  Android / iOS                              │
└─────────────────────────────────────────────────────────────┘
````

## Installation

Add this to your plugin's `pubspec.yaml`:

```yaml
dependencies:
  result_channel:
    git:
      url: [https://github.com/JonathanVegasP/result_channel.git](https://github.com/JonathanVegasP/result_channel.git)
````

## Example

For a complete example of how to use Result Channel in a plugin, check out:

**[Flutter Location FFI Plugin](https://github.com/JonathanVegasP/flutter_location_ffi)**

This plugin demonstrates how to use Result Channel to create high-performance native location services with FFI.

## Native Library Integration

### Android Setup

Configure your Android native code to be accessible via FFI with proper CMake setup.

**Example CMake Setup**

```cmake
cmake_minimum_required(VERSION 3.10)

project(your_library_library VERSION 1.0.0 LANGUAGES CXX)

find_package(result_channel CONFIG REQUIRED)

add_library(your_library SHARED "your_file_implementation.cpp")

set_target_properties(your_library PROPERTIES PUBLIC_HEADER your_library.h OUTPUT_NAME "your_library")

target_link_libraries(your_library PUBLIC result_channel::result_channel)

target_compile_definitions(your_library PUBLIC DART_SHARED_LIB)

if (ANDROID)
    target_link_options(your_library PRIVATE "-Wl,-z,max-page-size=16384")
endif ()
```

**Example Gradle Setup**

Add the following to your Android module's `build.gradle` file:

```gradle
android {
    ndkVersion = "27.2.12479018"

    externalNativeBuild {
        cmake {
            path = "../src/CMakeLists.txt"
        }
    }

    buildFeatures {
        prefab true
    }

    defaultConfig {
        ...
        externalNativeBuild {
            cmake {
                arguments "-Wl,--exclude-libs,ALL", "-Wl,--strip-all", "-Wl,--as-needed", "-Wl,--gc-sections", "-Wl,--relax", "-Wl,--reduce-memory-overheads", "-Wl,--build-id=none", "-DANDROID_STL=none"
                cppFlags "-fno-ident", "-nostdlib++", "-noprofilelib", "-nostdinc++", "-fPIC", "-fno-async-exceptions", "-fno-asynchronous-unwind-tables", "-fdata-sections", "-fno-exceptions", "-ffunction-sections", "-fno-plt", "-fno-rtti", "-fno-rtti-data", "-fno-semantic-interposition", "-fno-stack-clash-protection", "-fno-stack-protector", "-fno-threadsafe-statics", "-fno-unwind-tables", "-fno-use-cxa_atexit", "-fvisibility=hidden", "-fwhole-program-vtables", "-flto", "-O3"
            }
        }
    }

    buildTypes {
        release {
            externalNativeBuild {
                cmake {
                    arguments "-Wl,--exclude-libs,ALL", "-Wl,--strip-all", "-Wl,--as-needed", "-Wl,--gc-sections", "-Wl,--relax", "-Wl,--reduce-memory-overheads", "-Wl,--build-id=none", "-DANDROID_STL=none"
                    cppFlags "-fno-ident", "-nostdlib++", "-noprofilelib", "-nostdinc++", "-fPIC", "-fno-async-exceptions", "-fno-asynchronous-unwind-tables", "-fdata-sections", "-fno-exceptions", "-ffunction-sections", "-fno-plt", "-fno-rtti", "-fno-rtti-data", "-fno-semantic-interposition", "-fno-stack-clash-protection", "-fno-stack-protector", "-fno-threadsafe-statics", "-fno-unwind-tables", "-fno-use-cxa_atexit", "-fvisibility=hidden", "-fwhole-program-vtables", "-flto", "-O3", "-DNDEBUG"
                }
            }
        }
    }
}
```

### iOS Setup

For iOS, you need to include a `.h` header file and use the `@_cdecl` attribute in Swift to expose functions to Dart via FFI.

**Example iOS Setup**

1.  **Create a Header File (`your_library.h`):**
    Create a header file that declares the functions you want to expose. Make sure to include `result_channel.h` and use `FFI_PLUGIN_EXPORT`.

    ```c
    // your_library.h
    #include <stdbool.h>
    #include <stdint.h>
    #import <result_channel/result_channel.h> // Import for FFI_PLUGIN_EXPORT

    // Example functions exposed to Dart
    FFI_PLUGIN_EXPORT bool initialize_your_library(void);
    FFI_PLUGIN_EXPORT int32_t add_numbers(int32_t a, int32_t b);
    ```

2.  **Implement and Expose Functions in Swift (`your_library_implementation.swift`):**
    Implement the functions in a Swift file and use `@_cdecl` to make them callable from Dart.

    ```swift
    // your_library_implementation.swift
    import Foundation

    /// Example function exposed to Dart using @_cdecl
    @_cdecl("initialize_your_library")
    public func initialize_your_library() -> Bool {
        print("Your Library Initialized from Swift!")
        return true
    }

    /// Example function exposed to Dart using @_cdecl
    @_cdecl("add_numbers")
    public func add_numbers(_ a: Int32, _ b: Int32) -> Int32 {
        return a + b
    }
    ```

3.  **Update your `.podspec` file:**
    Ensure your plugin's `.podspec` file includes a dependency on `result_channel`.

    ```ruby
    # your_plugin.podspec
    # ... other podspec configurations ...

    s.dependency 'result_channel'

    # ... rest of your podspec ...
    ```

## Dart Usage Example

Here is a practical example of how a plugin can use `ResultChannel` to call a native FFI function and safely retrieve the result in Dart:

```dart
import 'dart:ffi';
import 'package:result_channel/result_channel.dart';

// Define the native function signature (e.g., int32_t add_numbers(int32_t, int32_t))
typedef NativeAddNumbers = Pointer<ResultNative> Function(Int32 a, Int32 b);
typedef DartAddNumbers = Pointer<ResultNative> Function(int a, int b);

final DynamicLibrary nativeLib = DynamicLibrary.open('libyour_library.so'); // or .framework on iOS

final DartAddNumbers addNumbers = nativeLib
  .lookup<NativeFunction<NativeAddNumbers>>('add_numbers')
  .asFunction();

void main() async {
  // Call the native function
  final Pointer<ResultNative> resultPtr = addNumbers(2, 3);

  // Convert to ResultDart using the ResultChannel extension
  final result = resultPtr.toResultDart();

  if (result.status == ResultStatus.ok) {
    print('Result: ${result.data}');
  } else {
    print('Error calling native function');
  }
}
```

> **Note:** Adjust the function name, parameters, and library name according to your native code.

## Best Practices

### Memory Management

Always ensure proper memory cleanup when working with FFI pointers. Or use toResultDart that do it by itself

### Error Handling

Implement proper error handling for native function calls.

## Contributing

This is infrastructure code that other plugins depend on. When contributing:

1.  **Maintain backward compatibility** - other plugins depend on the API
2.  **Add comprehensive tests** - ensure reliability for dependent plugins
3.  **Document breaking changes** - provide migration guides
4.  **Performance matters** - this is a performance-focused library

## Requirements

  - Flutter SDK: \>= 3.32.0
  - Dart SDK: \>= 3.8.0
  - Android: API level 21+ (for FFI support)
  - iOS: 12.0+ (for FFI support)

## License

MIT License - see [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

## Support

  - **Issues**: [GitHub Issues](https://github.com/JonathanVegasP/result_channel/issues)
  - **Documentation**: [Flutter FFI Guide](https://docs.flutter.dev/platform-integration/c-interop)
  - **Examples**: Check the `example/` directory for usage patterns

-----

**Infrastructure for Flutter Native Interop by [Jonathan Vegas](https://github.com/JonathanVegasP)**
