import 'dart:typed_data';

abstract class Reader {
  int readByte();

  int readChar();

  int readInt();

  int readLong();

  double readFloat();

  double readDouble();

  String readString(int size);

  Uint8List readUint8List(int size);

  Int32List readInt32List(int size);

  Int64List readInt64List(int size);

  Float32List readFloat32List(int size);

  Float64List readFloat64List(int size);
}
