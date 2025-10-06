import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'ffi.dart' as lib;
import 'result_dart.dart';
import 'result_native.dart';
import 'result_native_extensions.dart';
import 'typedefs.dart';

abstract final class ResultChannel {
  static AsyncCallbackRecord _createAsyncCallback() {
    final completer = Completer<ResultDart>();

    final ptr = NativeCallable<CallbackNative>.listener(
      (Pointer<ResultNative> ptr) => completer.complete(ptr.toResultDart()),
    );

    return (
      nativeFunction: ptr.nativeFunction,
      future: completer.future.whenComplete(ptr.close),
    );
  }

  static void registerClass(String javaClassName) {
    final classNamePtr = javaClassName.toNativeUtf8();
    try {
      lib.registerClass(classNamePtr);
    } finally {
      malloc.free(classNamePtr);
    }
  }

  static void callStaticVoid(String javaClassName, String methodName) {
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();
    try {
      lib.callStaticVoid(classNamePtr, methodNamePtr);
    } finally {
      malloc.free(classNamePtr);
      malloc.free(methodNamePtr);
    }
  }

  static void callStaticVoidWithArgs(
    String javaClassName,
    String methodName,
    ResultDart args,
  ) {
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();
    final native = args.toNative();
    try {
      lib.callStaticVoidWithArgs(classNamePtr, methodNamePtr, native);
    } finally {
      malloc.free(classNamePtr);
      malloc.free(methodNamePtr);
      native.free();
    }
  }

  static ResultDart callStaticReturn(String javaClassName, String methodName) {
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();
    try {
      return lib.callStaticReturn(classNamePtr, methodNamePtr).toResultDart();
    } finally {
      malloc.free(classNamePtr);
      malloc.free(methodNamePtr);
    }
  }

  static ResultDart callStaticReturnWithArgs(
    String javaClassName,
    String methodName,
    ResultDart args,
  ) {
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();
    final native = args.toNative();
    try {
      return lib
          .callStaticReturnWithArgs(classNamePtr, methodNamePtr, native)
          .toResultDart();
    } finally {
      malloc.free(classNamePtr);
      malloc.free(methodNamePtr);
      native.free();
    }
  }

  static Future<ResultDart> callStaticVoidAsync(
    String javaClassName,
    String methodName,
  ) {
    final callback = _createAsyncCallback();

    callStaticVoidAsyncNative(
      javaClassName,
      methodName,
      callback.nativeFunction,
    );

    return callback.future;
  }

  static void callStaticVoidAsyncNative(
    String javaClassName,
    String methodName,
    CallbackNativePointer callback,
  ) {
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();

    try {
      lib.callStaticVoidAsync(classNamePtr, methodNamePtr, callback);
    } finally {
      malloc.free(classNamePtr);
      malloc.free(methodNamePtr);
    }
  }

  static Future<ResultDart> callStaticVoidAsyncWithArgs(
    String javaClassName,
    String methodName,
    ResultDart args,
  ) {
    final callback = _createAsyncCallback();

    callStaticVoidAsyncWithArgsNative(
      javaClassName,
      methodName,
      callback.nativeFunction,
      args,
    );

    return callback.future;
  }

  static void callStaticVoidAsyncWithArgsNative(
    String javaClassName,
    String methodName,
    CallbackNativePointer callback,
    ResultDart args,
  ) {
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();
    final nativeArgs = args.toNative();

    try {
      lib.callStaticVoidAsyncWithArgs(
        classNamePtr,
        methodNamePtr,
        callback,
        nativeArgs,
      );
    } finally {
      malloc.free(classNamePtr);
      malloc.free(methodNamePtr);
      nativeArgs.free();
    }
  }

  static final FreePointerDart free = lib.freePointer;
}
