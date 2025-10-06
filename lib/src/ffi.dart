import 'dart:ffi';
import 'dart:io';

import 'typedefs.dart';

final _lib = (() {
  const lib = "result_channel";

  return switch (Platform.operatingSystem) {
    'android' => DynamicLibrary.open('lib$lib.so'),
    'ios' => DynamicLibrary.open('$lib.framework/$lib'),
    _ => throw UnsupportedError("Current platform is not supported"),
  };
})();

final RegisterClassDart registerClass = _lib
    .lookup<NativeFunction<RegisterClassNative>>(
      FlutterResultChannelFunctions.registerClass,
    )
    .asFunction<RegisterClassDart>();

final CallStaticVoidDart callStaticVoid = _lib
    .lookup<NativeFunction<CallStaticVoidNative>>(
      FlutterResultChannelFunctions.callStaticVoid,
    )
    .asFunction<CallStaticVoidDart>();

final CallStaticVoidWithArgsDart callStaticVoidWithArgs = _lib
    .lookup<NativeFunction<CallStaticVoidWithArgsNative>>(
      FlutterResultChannelFunctions.callStaticVoidWithArgs,
    )
    .asFunction<CallStaticVoidWithArgsDart>();

final CallStaticReturnDart callStaticReturn = _lib
    .lookup<NativeFunction<CallStaticReturnNative>>(
      FlutterResultChannelFunctions.callStaticReturn,
    )
    .asFunction<CallStaticReturnDart>();

final CallStaticReturnWithArgsDart callStaticReturnWithArgs = _lib
    .lookup<NativeFunction<CallStaticReturnWithArgsNative>>(
      FlutterResultChannelFunctions.callStaticReturnWithArgs,
    )
    .asFunction<CallStaticReturnWithArgsDart>();

final CallStaticVoidAsyncDart callStaticVoidAsync = _lib
    .lookup<NativeFunction<CallStaticVoidAsyncNative>>(
      FlutterResultChannelFunctions.callStaticVoidAsync,
    )
    .asFunction<CallStaticVoidAsyncDart>();

final CallStaticVoidAsyncWithArgsDart callStaticVoidAsyncWithArgs = _lib
    .lookup<NativeFunction<CallStaticVoidAsyncWithArgsNative>>(
      FlutterResultChannelFunctions.callStaticVoidAsyncWithArgs,
    )
    .asFunction<CallStaticVoidAsyncWithArgsDart>();

final FreePointerDart freePointer = _lib
    .lookup<NativeFunction<FreePointerNative>>(
      FlutterResultChannelFunctions.freePointer,
    )
    .asFunction<FreePointerDart>();
