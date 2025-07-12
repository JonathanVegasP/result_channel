import 'dart:convert';
import 'dart:typed_data';

import 'reader.dart';

class BinaryReader implements Reader {
  final Uint8List _byteArray;
  final ByteData _byteData;
  static final Endian _ORDER = Endian.host;

  int _offset = 0;

  BinaryReader(this._byteArray)
    : _byteData = _byteArray.buffer.asByteData(
        _byteArray.offsetInBytes,
        _byteArray.lengthInBytes,
      );

  @pragma("vm:prefer-inline")
  void _readPadding(int alignment) {
    final mod = _offset % alignment;

    if (mod == 0) {
      return;
    }

    _offset += (alignment - mod);
  }

  @pragma("vm:prefer-inline")
  @override
  int readByte() {
    return _byteArray[_offset++];
  }

  @pragma("vm:prefer-inline")
  @override
  int readChar() {
    _readPadding(Int16List.bytesPerElement);
    final value = _byteData.getUint16(_offset, _ORDER);
    _offset += Int16List.bytesPerElement;
    return value;
  }

  @pragma("vm:prefer-inline")
  @override
  int readInt() {
    _readPadding(Int32List.bytesPerElement);
    final value = _byteData.getInt32(_offset, _ORDER);
    _offset += Int32List.bytesPerElement;
    return value;
  }

  @pragma("vm:prefer-inline")
  @override
  int readLong() {
    _readPadding(Int64List.bytesPerElement);
    final value = _byteData.getInt64(_offset, _ORDER);
    _offset += Int64List.bytesPerElement;
    return value;
  }

  @pragma("vm:prefer-inline")
  @override
  double readFloat() {
    _readPadding(Float32List.bytesPerElement);
    final value = _byteData.getFloat32(_offset, _ORDER);
    _offset += Float32List.bytesPerElement;
    return value;
  }

  @pragma("vm:prefer-inline")
  @override
  double readDouble() {
    _readPadding(Float64List.bytesPerElement);
    final value = _byteData.getFloat64(_offset, _ORDER);
    _offset += Float64List.bytesPerElement;
    return value;
  }

  @pragma("vm:prefer-inline")
  @override
  String readString(int size) {
    final bytes = readUint8List(size);
    return utf8.decoder.convert(bytes);
  }

  @pragma("vm:prefer-inline")
  @override
  Uint8List readUint8List(int size) {
    final bytes = Uint8List.sublistView(_byteArray, _offset, _offset + size);
    _offset += size;
    return bytes;
  }

  @pragma("vm:prefer-inline")
  @override
  Int32List readInt32List(int size) {
    _readPadding(Int32List.bytesPerElement);
    final list = _byteArray.buffer.asInt32List(_offset, size);
    _offset += size * Int32List.bytesPerElement;
    return list;
  }

  @pragma("vm:prefer-inline")
  @override
  Int64List readInt64List(int size) {
    _readPadding(Int64List.bytesPerElement);
    final list = _byteArray.buffer.asInt64List(_offset, size);
    _offset += size * Int64List.bytesPerElement;
    return list;
  }

  @pragma("vm:prefer-inline")
  @override
  Float32List readFloat32List(int size) {
    _readPadding(Float32List.bytesPerElement);
    final list = _byteArray.buffer.asFloat32List(_offset, size);
    _offset += size * Float32List.bytesPerElement;
    return list;
  }

  @pragma("vm:prefer-inline")
  @override
  Float64List readFloat64List(int size) {
    _readPadding(Float64List.bytesPerElement);
    final list = _byteArray.buffer.asFloat64List(_offset, size);
    _offset += size * Float64List.bytesPerElement;
    return list;
  }
}
