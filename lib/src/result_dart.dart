import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'result_status.dart';

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

    pointer.ref
      ..data = nullptr
      ..status = 0
      ..size = 0;

    return pointer;
  }
}
