# Result Channel

Uma biblioteca de infraestrutura Flutter que fornece uma camada de abstração simplificada para outros plugins implementarem chamadas nativas FFI (Foreign Function Interface) e JNI (Java Native Interface). Pense nela como um helper para "Dart Native Interop".

## Visão Geral

**Result Channel** não é um plugin para usuários finais, mas sim uma **biblioteca de fundação** projetada para ajudar desenvolvedores de plugins a criar pontes nativas de alta performance usando FFI e JNI. Ela abstrai a complexidade das chamadas FFI/JNI diretas, fornecendo uma interface limpa e type-safe para chamar funções nativas do Dart.

## Propósito

Este plugin serve como:

-   **Camada de Infraestrutura**: Base para outros plugins construírem sobre
-   **Abstração FFI/JNI**: Simplifica a complexidade de chamadas FFI e JNI diretas
-   **Type Safety**: Fornece interfaces fortemente tipadas entre Dart e código nativo
-   **Otimização de Performance**: Habilita chamadas nativas síncronas e assíncronas de alta performance
-   **Ponte Cross-Platform**: Interface unificada para interoperabilidade nativa Android e iOS
-   **Serialização Binária**: Sistema eficiente de serialização para transferência de dados entre Dart e código nativo

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                  Aplicação Flutter                         │
├─────────────────────────────────────────────────────────────┤
│                   Seu Plugin                                │
├─────────────────────────────────────────────────────────────┤
│                 Result Channel                              │
│           (Camada de Abstração FFI/JNI)                    │
├─────────────────────────────────────────────────────────────┤
│         Bibliotecas Nativas (C/C++/Java/Kotlin)            │
│                  Android / iOS                              │
└─────────────────────────────────────────────────────────────┘
```

## Instalação

Adicione isto ao `pubspec.yaml` do seu plugin:

```yaml
dependencies:
  result_channel:
    git:
      url: https://github.com/JonathanVegasP/result_channel.git
```

## API Principal

### ResultChannel

Classe principal que fornece métodos estáticos para interação com código nativo:

#### Gerenciamento de Classes
```dart
// Registra uma classe Java/Kotlin para uso
ResultChannel.registerClass(String javaClassName)
```

#### Chamadas Síncronas
```dart
// Chama método estático sem argumentos, sem retorno
ResultChannel.callStaticVoid(String javaClassName, String methodName)

// Chama método estático com argumentos, sem retorno  
ResultChannel.callStaticVoidWithArgs(String javaClassName, String methodName, ResultDart args)

// Chama método estático sem argumentos, com retorno
ResultChannel.callStaticReturn(String javaClassName, String methodName)

// Chama método estático com argumentos e retorno
ResultChannel.callStaticReturnWithArgs(String javaClassName, String methodName, ResultDart args)
```

#### Chamadas Assíncronas
```dart
// Chama método assíncrono sem argumentos
Future<ResultDart> callStaticVoidAsync(String javaClassName, String methodName)

// Chama método assíncrono com argumentos
Future<ResultDart> callStaticVoidAsyncWithArgs(String javaClassName, String methodName, ResultDart args)
```

### ResultDart

Classe que encapsula dados e status de operações:

```dart
// Construtores
ResultDart({required ResultChannelStatus status, required Object? data})
ResultDart.ok(Object? data)      // Cria resultado de sucesso
ResultDart.error(Object? data)   // Cria resultado de erro

// Propriedades
bool get isOk                    // Verifica se operação foi bem-sucedida
bool get isError                 // Verifica se houve erro
bool get hasData                 // Verifica se há dados
ResultChannelStatus status       // Status da operação
Object? data                     // Dados da operação

// Métodos
Pointer<ResultNative> toNative() // Converte para estrutura nativa
```

### ResultChannelStatus

Enum que define os status possíveis:

```dart
enum ResultChannelStatus { 
  ok,     // Operação bem-sucedida
  error   // Erro na operação
}
```

### Extensões FFI

Para trabalhar diretamente com ponteiros FFI:

```dart
extension ResultNativeExt on Pointer<ResultNative> {
  void free()                    // Libera memória do ponteiro
  ResultDart toResultDart()      // Converte ponteiro nativo para ResultDart
}
```

## Serialização Binária

O Result Channel inclui um sistema robusto de serialização binária que suporta:

### Tipos Primitivos
- `null`
- `bool` (true/false)
- `int` (32-bit e 64-bit automático)
- `double`
- `String` (com otimização UTF-8)

### Arrays Tipados
- `Uint8List` (byte arrays)
- `Int32List` (int arrays)
- `Int64List` (long arrays)  
- `Float32List` (float arrays)
- `Float64List` (double arrays)

### Coleções
- `List<dynamic>` (listas heterogêneas)
- `Set<dynamic>` (conjuntos)
- `Map<dynamic, dynamic>` (mapas chave-valor)

## Exemplo de Uso em Dart

### Chamadas JNI (Android)

```dart
import 'package:result_channel/result_channel.dart';

void main() async {
  // Registrar classe Java
  ResultChannel.registerClass('com.example.MyNativeClass');
  
  // Chamada síncrona simples
  final result = ResultChannel.callStaticReturn(
    'com.example.MyNativeClass', 
    'getData'
  );
  
  if (result.isOk) {
    print('Dados recebidos: ${result.data}');
  }
  
  // Chamada com argumentos
  final args = ResultDart.ok({'param1': 'valor', 'param2': 42});
  final resultWithArgs = ResultChannel.callStaticReturnWithArgs(
    'com.example.MyNativeClass',
    'processData',
    args
  );
  
  // Chamada assíncrona
  final asyncResult = await ResultChannel.callStaticVoidAsync(
    'com.example.MyNativeClass',
    'performAsyncOperation'
  );
}
```

### Chamadas FFI Diretas

```dart
import 'dart:ffi';
import 'package:result_channel/result_channel.dart';

// Definir assinatura da função nativa
typedef NativeAddNumbers = Pointer<ResultNative> Function(Int32 a, Int32 b);
typedef DartAddNumbers = Pointer<ResultNative> Function(int a, int b);

final DynamicLibrary nativeLib = DynamicLibrary.open('libyour_library.so');

final DartAddNumbers addNumbers = nativeLib
  .lookup<NativeFunction<NativeAddNumbers>>('add_numbers')
  .asFunction();

void main() async {
  // Chamar função nativa
  final Pointer<ResultNative> resultPtr = addNumbers(2, 3);

  // Converter para ResultDart usando a extensão do ResultChannel
  final result = resultPtr.toResultDart();

  if (result.isOk) {
    print('Resultado: ${result.data}');
  } else {
    print('Erro ao chamar função nativa');
  }
}
```#
# Native Library Integration

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

## Melhores Práticas

### Gerenciamento de Memória

Sempre garanta a limpeza adequada da memória ao trabalhar com ponteiros FFI. Use `toResultDart()` que faz isso automaticamente.

### Tratamento de Erros

Implemente tratamento adequado de erros para chamadas de funções nativas usando `ResultChannelStatus`.

### Serialização de Dados

O Result Channel usa serialização binária eficiente para transferir dados complexos entre Dart e código nativo. Tipos suportados incluem:
- Primitivos (int, double, bool, String)
- Listas e Maps
- Objetos serializáveis customizados

## Contribuindo

Este é código de infraestrutura do qual outros plugins dependem. Ao contribuir:

1.  **Mantenha compatibilidade retroativa** - outros plugins dependem da API
2.  **Adicione testes abrangentes** - garanta confiabilidade para plugins dependentes
3.  **documente mudanças que quebram compatibilidade** - forneça guias de migração
4.  **Performance importa** - esta é uma biblioteca focada em performance

## Requisitos

  - Flutter SDK: >= 3.3.0
  - Dart SDK: >= 3.8.1
  - Android: API level 21+ (para suporte FFI/JNI)
  - iOS: 12.0+ (para suporte FFI)

## License

MIT License - see [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

## Support

  - **Issues**: [GitHub Issues](https://github.com/JonathanVegasP/result_channel/issues)
  - **Documentation**: [Flutter FFI Guide](https://docs.flutter.dev/platform-integration/c-interop)

-----

**Infrastructure for Flutter Native Interop by [Jonathan Vegas](https://github.com/JonathanVegasP)**