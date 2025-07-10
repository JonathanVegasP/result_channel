import 'dart:typed_data';

abstract interface class Writer {
  void putByte(int value);
  void putChar(int value);
  void putInt(int value);
  void putLong(int value);
  void putFloat(double value);
  void putDouble(double value);
  void putUint8List(Uint8List value);
  void putInt32List(Int32List value);
  void putInt64List(Int64List value);
  void putFloat32List(Float32List value);
  void putFloat64List(Float64List value);

  Uint8List toUint8List();
}
