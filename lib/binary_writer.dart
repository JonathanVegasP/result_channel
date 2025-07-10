import 'dart:typed_data';

import 'writer.dart';

class BinaryWriter implements Writer {
  static const int _INITIAL_SIZE = 1024;
  static final Endian _ORDER = Endian.host;

  Uint8List _buffer = Uint8List(_INITIAL_SIZE);
  int _offset = 0;

  late ByteData _byteData;

  BinaryWriter() {
    _byteData = _buffer.buffer.asByteData(
      _buffer.offsetInBytes,
      _buffer.lengthInBytes,
    );
  }

  @pragma("vm:prefer-inline")
  void _growBufferIfNeeded(int size) {
    final requiredSize = _offset + size;
    final buffer = _buffer;
    final capacity = buffer.length;

    if (requiredSize <= capacity) {
      return;
    }

    var newCapacity = capacity << 1;
    while (newCapacity < requiredSize) {
      newCapacity <<= 1;
    }

    final newBuffer = Uint8List(newCapacity);
    newBuffer.setRange(0, _offset, buffer);

    _buffer = newBuffer;
    _byteData = newBuffer.buffer.asByteData(
      buffer.offsetInBytes,
      buffer.lengthInBytes,
    );
  }

  @pragma("vm:prefer-inline")
  void _addPaddingIfNeeded(int alignment) {
    final remainder = _offset % alignment;

    if (remainder == 0) {
      return;
    }

    final size = alignment - remainder;

    _growBufferIfNeeded(size);

    for (int i = 0; i < size; i++) {
      _buffer[_offset++] = 0x00;
    }
  }

  @pragma("vm:prefer-inline")
  @override
  void putByte(int value) {
    _growBufferIfNeeded(1);
    _buffer[_offset++] = value & 0xFF;
  }

  @pragma("vm:prefer-inline")
  @override
  void putChar(int value) {
    _addPaddingIfNeeded(2);
    _growBufferIfNeeded(2);
    _byteData.setUint16(_offset, value, _ORDER);
    _offset += 2;
  }

  @pragma("vm:prefer-inline")
  @override
  void putInt(int value) {
    _addPaddingIfNeeded(4);
    _growBufferIfNeeded(4);
    _byteData.setInt32(_offset, value, _ORDER);
    _offset += 4;
  }

  @pragma("vm:prefer-inline")
  @override
  void putLong(int value) {
    _addPaddingIfNeeded(8);
    _growBufferIfNeeded(8);
    _byteData.setInt64(_offset, value, _ORDER);
    _offset += 8;
  }

  @pragma("vm:prefer-inline")
  @override
  void putFloat(double value) {
    _addPaddingIfNeeded(4);
    _growBufferIfNeeded(4);
    _byteData.setFloat32(_offset, value, _ORDER);
    _offset += 4;
  }

  @pragma("vm:prefer-inline")
  @override
  void putDouble(double value) {
    _addPaddingIfNeeded(8);
    _growBufferIfNeeded(8);
    _byteData.setFloat64(_offset, value, _ORDER);
    _offset += 8;
  }

  @pragma("vm:prefer-inline")
  @override
  void putUint8List(Uint8List value) {
    final size = value.length;
    _growBufferIfNeeded(size);
    _buffer.setAll(_offset, value);
    _offset += size;
  }

  @pragma("vm:prefer-inline")
  @override
  void putInt32List(Int32List value) {
    _addPaddingIfNeeded(4);
    _growBufferIfNeeded(value.length * 4);
    for (int i = 0; i < value.length; i++) {
      _byteData.setInt32(_offset + i * 4, value[i], _ORDER);
    }
    _offset += value.length * 4;
  }

  @pragma("vm:prefer-inline")
  @override
  void putInt64List(Int64List value) {
    _addPaddingIfNeeded(8);
    _growBufferIfNeeded(value.length * 8);
    for (int i = 0; i < value.length; i++) {
      _byteData.setInt64(_offset + i * 8, value[i], _ORDER);
    }
    _offset += value.length * 8;
  }

  @pragma("vm:prefer-inline")
  @override
  void putFloat32List(Float32List value) {
    _addPaddingIfNeeded(4);
    _growBufferIfNeeded(value.length * 4);
    for (int i = 0; i < value.length; i++) {
      _byteData.setFloat32(_offset + i * 4, value[i], _ORDER);
    }
    _offset += value.length * 4;
  }

  @pragma("vm:prefer-inline")
  @override
  void putFloat64List(Float64List value) {
    _addPaddingIfNeeded(8);
    _growBufferIfNeeded(value.length * 8);
    for (int i = 0; i < value.length; i++) {
      _byteData.setFloat64(_offset + i * 8, value[i], _ORDER);
    }
    _offset += value.length * 8;
  }

  @pragma("vm:prefer-inline")
  @override
  Uint8List toUint8List() {
    return _byteData.buffer.asUint8List(0, _offset);
  }
}
