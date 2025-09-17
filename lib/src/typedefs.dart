import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'result_dart.dart';
import 'result_native.dart';

typedef CallbackNative = Void Function(Pointer<ResultNative>);

typedef RegisterClassNative = Void Function(Pointer<Utf8> javaClassName);

typedef RegisterClassDart = void Function(Pointer<Utf8> javaClassName);

typedef CallStaticVoidNative =
    Void Function(Pointer<Utf8> javaClassName, Pointer<Utf8> methodName);

typedef CallStaticVoidDart =
    void Function(Pointer<Utf8> javaClassName, Pointer<Utf8> methodName);

typedef CallStaticVoidWithArgsNative =
    Void Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<ResultNative> args,
    );

typedef CallStaticVoidWithArgsDart =
    void Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<ResultNative> args,
    );

typedef CallStaticReturnNative =
    Pointer<ResultNative> Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
    );

typedef CallStaticReturnDart =
    Pointer<ResultNative> Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
    );

typedef CallStaticReturnWithArgsNative =
    Pointer<ResultNative> Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<ResultNative> args,
    );

typedef CallStaticReturnWithArgsDart =
    Pointer<ResultNative> Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<ResultNative> args,
    );

typedef CallStaticVoidAsyncNative =
    Void Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<NativeFunction<CallbackNative>> callback,
    );

typedef CallStaticVoidAsyncDart =
    void Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<NativeFunction<CallbackNative>> callback,
    );

typedef CallStaticVoidAsyncWithArgsNative =
    Void Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<NativeFunction<CallbackNative>> callback,
      Pointer<ResultNative> args,
    );

typedef CallStaticVoidAsyncWithArgsDart =
    void Function(
      Pointer<Utf8> javaClassName,
      Pointer<Utf8> methodName,
      Pointer<NativeFunction<CallbackNative>> callback,
      Pointer<ResultNative> args,
    );

typedef FreePointerNative = Void Function(Pointer<Void> pointer);

typedef FreePointerDart = void Function(Pointer<Void> pointer);

typedef AsyncCallbackRecord = ({
  Pointer<NativeFunction<CallbackNative>> nativeFunction,
  Future<ResultDart> future,
});

abstract final class FlutterResultChannelFunctions {
  static const String registerClass = 'flutter_result_channel_register_class';
  static const String callStaticVoid =
      'flutter_result_channel_call_static_void';
  static const String callStaticVoidWithArgs =
      'flutter_result_channel_call_static_void_with_args';
  static const String callStaticReturn =
      'flutter_result_channel_call_static_return';
  static const String callStaticReturnWithArgs =
      'flutter_result_channel_call_static_return_with_args';
  static const String callStaticVoidAsync =
      'flutter_result_channel_call_static_void_async';
  static const String callStaticVoidAsyncWithArgs =
      'flutter_result_channel_call_static_void_async_with_args';
  static const String freePointer = 'flutter_result_channel_free_pointer';
}
