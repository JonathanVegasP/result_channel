import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'binary_serializer.dart';
import 'ffi.dart';
import 'result_channel_status.dart';
import 'result_dart.dart';
import 'result_native.dart';

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
      final result = BinarySerializer.deserialize(bytes);
      resultDart = ResultDart(
        status: ResultChannelStatus.values[value.status],
        data: result,
      );
    } finally {
      freePointer(data.cast());
      freePointer(cast());
    }

    return resultDart;
  }
}
