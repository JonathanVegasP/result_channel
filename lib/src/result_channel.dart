import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'binary_serializer.dart';
import 'result_dart.dart';
import 'result_status.dart';
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
  @pragma("vm:prefer-inline")
  void free() {
    malloc.free(ref.data);
    malloc.free(this);
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

abstract final class ResultChannel {
  static const serializer = BinarySerializer();

  @pragma('vm:prefer-inline')
  static Object checkApplicationError() {
    return StateError(
      'Application lifecycle: process termination or memory release initiated.',
    );
  }

  @pragma('vm:prefer-inline')
  static ({
    ResultChannelCallbackNative nativeFunction,
    Future<ResultDart> future,
  })
  createHandler() {
    final completer = Completer<ResultDart>();

    final ptr = NativeCallable<ResultChannelCallback>.listener(
      (Pointer<ResultNative> ptr) => completer.complete(ptr.toResultDart()),
    );

    return (
      nativeFunction: ptr.nativeFunction,
      future: completer.future.whenComplete(ptr.close),
    );
  }

  static final void Function(Pointer<Void>) free = _lib
      .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
        'flutter_result_channel_free_pointer',
      )
      .asFunction<void Function(Pointer<Void>)>();
}
