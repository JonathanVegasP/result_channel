import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:result_channel/result_channel.dart';

final class ResultNative extends Struct {
  @Uint8()
  external int status;

  external Pointer<Uint8> data;

  @Int32()
  external int size;
}

final class ResultDart {
  final ResultStatus status;
  final Object? data;

  const ResultDart({required this.status, required this.data});

  @pragma('vm:prefer-inline')
  Pointer<ResultNative> toResultNative() {
    final pointer = malloc<ResultNative>();

    final bytes = ResultChannel.serializer.serialize(data);

    final length = bytes.length;

    final bytesPointer = malloc<Uint8>(length);

    bytesPointer.asTypedList(length).setAll(0, bytes);

    pointer.ref
      ..data = bytesPointer
      ..status = status.index
      ..size = 0;

    return pointer;
  }
}
