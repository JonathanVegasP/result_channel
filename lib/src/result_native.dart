import 'dart:ffi';

final class ResultNative extends Struct {
  @Uint8()
  external int status;

  external Pointer<Uint8> data;

  @Size()
  external int size;
}
