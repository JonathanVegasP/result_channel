import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'binary_serializer.dart';
import 'result_channel_status.dart';
import 'result_native.dart';

final class ResultDart {
  final ResultChannelStatus status;
  final Object? data;

  const ResultDart({required this.status, required this.data});

  const ResultDart.ok(this.data) : status = ResultChannelStatus.ok;

  const ResultDart.error(this.data) : status = ResultChannelStatus.error;

  bool get isOk => status == ResultChannelStatus.ok;

  bool get isError => status == ResultChannelStatus.error;

  bool get hasData => data != null;

  Pointer<ResultNative> toNative() {
    final serializer = BinarySerializer();

    final bytes = serializer.serialize(data);

    final length = bytes.length;

    final bytesPointer = malloc<Uint8>(length);

    bytesPointer.asTypedList(length).setAll(0, bytes);

    final pointer = malloc<ResultNative>();

    pointer.ref
      ..data = bytesPointer
      ..status = status.index
      ..size = length;

    return pointer;
  }
}
