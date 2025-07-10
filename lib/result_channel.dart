import 'dart:ffi';
import 'dart:io';

import 'binary_serializer.dart';

final _lib = (() {
  const lib = "result_channel";

  return switch (Platform.operatingSystem) {
    'android' => DynamicLibrary.open('lib$lib.so'),
    'ios' => DynamicLibrary.open('$lib.framework/$lib'),
    _ => throw "Current platform is not supported",
  };
})();

typedef ResultChannelCallbackDart = void Function(int, Pointer<Uint8>, int);

typedef ResultChannelCallbackNative =
    Void Function(Uint8, Pointer<Uint8>, Int32);

abstract final class ResultChannel {
  static const serializer = BinarySerializer();

  static final void Function(Pointer<Void>) free = _lib
      .lookup<NativeFunction<Void Function(Pointer<Void>)>>('free_c_mem')
      .asFunction<void Function(Pointer<Void>)>();
}
