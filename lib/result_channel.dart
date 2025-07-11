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

final class ResultNative extends Struct {
  @Uint8()
  external int status;

  external Pointer<Uint8> data;

  @Int32()
  external int size;
}

extension ResultNativeExt on Pointer<ResultNative> {
  @pragma("vm:prefer-inline")
  ResultDart? toNullableResultDart() {
    if(this == nullptr) return null;

    return toResultDart();
  }

  @pragma("vm:prefer-inline")
  ResultDart toResultDart() {
    final value = ref;
    final data = ref.data;
    ResultDart resultDart;

    try {
      final bytes = data.asTypedList(value.size);
      final result = ResultChannel.serializer.deserialize(bytes);
      resultDart = ResultDart(
        status: ResultStatus.values[value.status],
        data: result,
      );
    } finally {
      ResultChannel.free(data.cast());
      ResultChannel.free(cast());
    }

    return resultDart;
  }
}

enum ResultStatus { ok, error }

final class ResultDart {
  final ResultStatus status;
  final Object? data;

  const ResultDart({required this.status, required this.data});
}

typedef ResultChannelCallbackDart = void Function(int, Pointer<Uint8>, int);

typedef ResultChannelCallbackNative =
    Void Function(Uint8, Pointer<Uint8>, Int32);

abstract final class ResultChannel {
  static const serializer = BinarySerializer();

  static final void Function(Pointer<Void>) free = _lib
      .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
        'flutter_result_channel_free_pointer',
      )
      .asFunction<void Function(Pointer<Void>)>();
}
