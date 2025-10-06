import 'dart:convert';
import 'dart:typed_data';

class BinaryReader {
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

  int getByte() {
    return _byteData.getUint8(_offset++);
  }

  int getChar() {
    _readPadding(Int16List.bytesPerElement);
    final value = _byteData.getUint16(_offset, _order);
    _offset += Int16List.bytesPerElement;
    return value;
  }

  int getInt() {
    _readPadding(Int32List.bytesPerElement);
    final value = _byteData.getInt32(_offset, _order);
    _offset += Int32List.bytesPerElement;
    return value;
  }

  int getLong() {
    _readPadding(Int64List.bytesPerElement);
    final value = _byteData.getInt64(_offset, _order);
    _offset += Int64List.bytesPerElement;
    return value;
  }

  double getDouble() {
    _readPadding(Float64List.bytesPerElement);
    final value = _byteData.getFloat64(_offset, _order);
    _offset += Float64List.bytesPerElement;
    return value;
  }

  Uint8List getUint8List(int size) {
    final bytes = Uint8List.sublistView(_byteArray, _offset, _offset + size);
    _offset += size;
    return bytes;
  }

  Int32List getInt32List(int size) {
    _readPadding(Int32List.bytesPerElement);
    final list = _byteArray.buffer.asInt32List(_offset, size);
    _offset += size << 2;
    return list;
  }

  Int64List getInt64List(int size) {
    _readPadding(Int64List.bytesPerElement);
    final list = _byteArray.buffer.asInt64List(_offset, size);
    _offset += size << 3;
    return list;
  }

  Float32List getFloat32List(int size) {
    _readPadding(Float32List.bytesPerElement);
    final list = _byteArray.buffer.asFloat32List(_offset, size);
    _offset += size << 2;
    return list;
  }

  Float64List getFloat64List(int size) {
    _readPadding(Float64List.bytesPerElement);
    final list = _byteArray.buffer.asFloat64List(_offset, size);
    _offset += size << 3;
    return list;
  }
}
