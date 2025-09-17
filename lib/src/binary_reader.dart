import 'dart:convert';
import 'dart:typed_data';

import 'reader.dart';

class BinaryReader implements Reader {
  final Uint8List _byteArray;
  final ByteData _byteData;
  final Endian _order = Endian.host;

  int _offset = 0;

  BinaryReader(this._byteArray)
    : _byteData = _byteArray.buffer.asByteData(
        _byteArray.offsetInBytes,
        _byteArray.lengthInBytes,
      );

  void _readPadding(int alignment) {
    final align = alignment - 1;
    _offset = (_offset + align) & ~align;
  }

  @override
  int readByte() {
    return _byteData.getUint8( _offset++);
  }

  @override
  int readChar() {
    _readPadding(Int16List.bytesPerElement);
    final value = _byteData.getUint16(_offset, _order);
    _offset += Int16List.bytesPerElement;
    return value;
  }

  @override
  int readInt() {
    _readPadding(Int32List.bytesPerElement);
    final value = _byteData.getInt32(_offset, _order);
    _offset += Int32List.bytesPerElement;
    return value;
  }

  @override
  int readLong() {
    _readPadding(Int64List.bytesPerElement);
    final value = _byteData.getInt64(_offset, _order);
    _offset += Int64List.bytesPerElement;
    return value;
  }

  @override
  double readFloat() {
    _readPadding(Float32List.bytesPerElement);
    final value = _byteData.getFloat32(_offset, _order);
    _offset += Float32List.bytesPerElement;
    return value;
  }

  @override
  double readDouble() {
    _readPadding(Float64List.bytesPerElement);
    final value = _byteData.getFloat64(_offset, _order);
    _offset += Float64List.bytesPerElement;
    return value;
  }

  @override
  String readString(int size) {
    final bytes = readUint8List(size);
    return utf8.decoder.convert(bytes);
  }

  @override
  Uint8List readUint8List(int size) {
    final bytes = Uint8List.sublistView(_byteArray, _offset, _offset + size);
    _offset += size;
    return bytes;
  }

  @override
  Int32List readInt32List(int size) {
    _readPadding(Int32List.bytesPerElement);
    final list = _byteArray.buffer.asInt32List(_offset, size);
    _offset += size << 2;
    return list;
  }

  @override
  Int64List readInt64List(int size) {
    _readPadding(Int64List.bytesPerElement);
    final list = _byteArray.buffer.asInt64List(_offset, size);
    _offset += size << 3;
    return list;
  }

  @override
  Float32List readFloat32List(int size) {
    _readPadding(Float32List.bytesPerElement);
    final list = _byteArray.buffer.asFloat32List(_offset, size);
    _offset += size << 2;
    return list;
  }

  @override
  Float64List readFloat64List(int size) {
    _readPadding(Float64List.bytesPerElement);
    final list = _byteArray.buffer.asFloat64List(_offset, size);
    _offset += size << 3;
    return list;
  }
}
