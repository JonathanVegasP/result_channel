import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'binary_serializer.dart';
import 'result_channel_status.dart';
import 'result_dart.dart';
import 'result_native.dart';
import 'typedefs.dart';

final _lib = (() {
  const lib = "result_channel";

  return switch (Platform.operatingSystem) {
    'android' => DynamicLibrary.open('lib$lib.so'),
    'ios' => DynamicLibrary.open('$lib.framework/$lib'),
    _ => throw "Current platform is not supported",
  };
})();

extension ResultNativeExt on Pointer<ResultNative> {
  void free() {
    malloc.free(ref.data);
    malloc.free(this);
  }

  ResultDart toResultDart() {
    final value = ref;
    final data = value.data;
    ResultDart resultDart;

    try {
      final bytes = data.asTypedList(value.size);
      final serializer = BinarySerializer();
      final result = serializer.deserialize(bytes);
      resultDart = ResultDart(
        status: ResultChannelStatus.values[value.status],
        data: result,
      );
    } finally {
      ResultChannel.free(data.cast());
      ResultChannel.free(cast());
    }

    return resultDart;
  }
}

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

  static final RegisterClassDart _registerClass = _lib
      .lookup<NativeFunction<RegisterClassNative>>(
        FlutterResultChannelFunctions.registerClass,
      )
      .asFunction<RegisterClassDart>();

  static final CallStaticVoidDart _callStaticVoid = _lib
      .lookup<NativeFunction<CallStaticVoidNative>>(
        FlutterResultChannelFunctions.callStaticVoid,
      )
      .asFunction<CallStaticVoidDart>();

  static final CallStaticVoidWithArgsDart _callStaticVoidWithArgs = _lib
      .lookup<NativeFunction<CallStaticVoidWithArgsNative>>(
        FlutterResultChannelFunctions.callStaticVoidWithArgs,
      )
      .asFunction<CallStaticVoidWithArgsDart>();

  static final CallStaticReturnDart _callStaticReturn = _lib
      .lookup<NativeFunction<CallStaticReturnNative>>(
        FlutterResultChannelFunctions.callStaticReturn,
      )
      .asFunction<CallStaticReturnDart>();

  static final CallStaticReturnWithArgsDart callStaticReturnWithArgsRaw = _lib
      .lookup<NativeFunction<CallStaticReturnWithArgsNative>>(
        FlutterResultChannelFunctions.callStaticReturnWithArgs,
      )
      .asFunction<CallStaticReturnWithArgsDart>();

  static final CallStaticVoidAsyncDart _callStaticVoidAsync = _lib
      .lookup<NativeFunction<CallStaticVoidAsyncNative>>(
        FlutterResultChannelFunctions.callStaticVoidAsync,
      )
      .asFunction<CallStaticVoidAsyncDart>();

  static final CallStaticVoidAsyncWithArgsDart callStaticVoidAsyncWithArgsRaw =
      _lib
          .lookup<NativeFunction<CallStaticVoidAsyncWithArgsNative>>(
            FlutterResultChannelFunctions.callStaticVoidAsyncWithArgs,
          )
          .asFunction<CallStaticVoidAsyncWithArgsDart>();

  static void registerClass(String javaClassName) {
    final classNamePtr = javaClassName.toNativeUtf8();
    try {
      _registerClass(classNamePtr);
    } finally {
      malloc.free(classNamePtr);
    }
  }

  static void callStaticVoid(String javaClassName, String methodName) {
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();
    try {
      _callStaticVoid(classNamePtr, methodNamePtr);
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
      _callStaticVoidWithArgs(classNamePtr, methodNamePtr, native);
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
      return _callStaticReturn(classNamePtr, methodNamePtr).toResultDart();
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
      return callStaticReturnWithArgsRaw(
        classNamePtr,
        methodNamePtr,
        native,
      ).toResultDart();
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
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();

    try {
      _callStaticVoidAsync(
        classNamePtr,
        methodNamePtr,
        callback.nativeFunction,
      );
      return callback.future;
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
    final classNamePtr = javaClassName.toNativeUtf8();
    final methodNamePtr = methodName.toNativeUtf8();
    final nativeArgs = args.toNative();

    try {
      callStaticVoidAsyncWithArgsRaw(
        classNamePtr,
        methodNamePtr,
        callback.nativeFunction,
        nativeArgs,
      );
      return callback.future;
    } finally {
      malloc.free(classNamePtr);
      malloc.free(methodNamePtr);
      nativeArgs.free();
    }
  }

  static final FreePointerDart free = _lib
      .lookup<NativeFunction<FreePointerNative>>(
        FlutterResultChannelFunctions.freePointer,
      )
      .asFunction<FreePointerDart>();
}
