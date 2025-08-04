import 'dart:typed_data';

import 'writer.dart';

class BinaryWriter implements Writer {
  static const int _INITIAL_SIZE = 1024;
  static final Endian _ORDER = Endian.host;

  Uint8List _buffer = Uint8List(_INITIAL_SIZE);
  final _zeroBuffer = Uint8List(8);
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

    if (capacity >= requiredSize) {
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
    final mask = alignment - 1;
    final offset = _offset;
    final remainder = offset & mask;

    if (remainder == 0) {
      return;
    }

    final size = alignment - remainder;

    _growBufferIfNeeded(size);

    final newSize = offset + size;

    _buffer.setRange(offset, newSize, _zeroBuffer);

    _offset = newSize;
  }

  @pragma("vm:prefer-inline")
  @override
  void putByte(int value) {
    _growBufferIfNeeded(1);
    _byteData.setUint8(_offset++, value);
  }

  @pragma("vm:prefer-inline")
  @override
  void putChar(int value) {
    _addPaddingIfNeeded(Int16List.bytesPerElement);
    _growBufferIfNeeded(Int16List.bytesPerElement);
    _byteData.setUint16(_offset, value, _ORDER);
    _offset += Int16List.bytesPerElement;
  }

  @pragma("vm:prefer-inline")
  @override
  void putInt(int value) {
    _addPaddingIfNeeded(Int32List.bytesPerElement);
    _growBufferIfNeeded(Int32List.bytesPerElement);
    _byteData.setInt32(_offset, value, _ORDER);
    _offset += Int32List.bytesPerElement;
  }

  @pragma("vm:prefer-inline")
  @override
  void putLong(int value) {
    _addPaddingIfNeeded(Int64List.bytesPerElement);
    _growBufferIfNeeded(Int64List.bytesPerElement);
    _byteData.setInt64(_offset, value, _ORDER);
    _offset += Int64List.bytesPerElement;
  }

  @pragma("vm:prefer-inline")
  @override
  void putFloat(double value) {
    _addPaddingIfNeeded(Float32List.bytesPerElement);
    _growBufferIfNeeded(Float32List.bytesPerElement);
    _byteData.setFloat32(_offset, value, _ORDER);
    _offset += Float32List.bytesPerElement;
  }

  @pragma("vm:prefer-inline")
  @override
  void putDouble(double value) {
    _addPaddingIfNeeded(Float64List.bytesPerElement);
    _growBufferIfNeeded(Float64List.bytesPerElement);
    _byteData.setFloat64(_offset, value, _ORDER);
    _offset += Float64List.bytesPerElement;
  }

  @pragma("vm:prefer-inline")
  @override
  void putUint8List(Uint8List value) {
    final size = value.length;
    _growBufferIfNeeded(size);
    _buffer.setRange(_offset, size, value);
    _offset += size;
  }

  @pragma("vm:prefer-inline")
  @override
  void putInt32List(Int32List value) {
    _addPaddingIfNeeded(Int32List.bytesPerElement);
    final bytes = value.buffer.asUint8List(
      value.offsetInBytes,
      value.lengthInBytes,
    );
    putUint8List(bytes);
  }

  @pragma("vm:prefer-inline")
  @override
  void putInt64List(Int64List value) {
    _addPaddingIfNeeded(Int64List.bytesPerElement);
    final bytes = value.buffer.asUint8List(
      value.offsetInBytes,
      value.lengthInBytes,
    );
    putUint8List(bytes);
  }

  @pragma("vm:prefer-inline")
  @override
  void putFloat32List(Float32List value) {
    _addPaddingIfNeeded(Float32List.bytesPerElement);
    final bytes = value.buffer.asUint8List(
      value.offsetInBytes,
      value.lengthInBytes,
    );
    putUint8List(bytes);
  }

  @pragma("vm:prefer-inline")
  @override
  void putFloat64List(Float64List value) {
    _addPaddingIfNeeded(Float64List.bytesPerElement);
    final bytes = value.buffer.asUint8List(
      value.offsetInBytes,
      value.lengthInBytes,
    );
    putUint8List(bytes);
  }

  @pragma("vm:prefer-inline")
  @override
  Uint8List toUint8List() {
    return _byteData.buffer.asUint8List(0, _offset);
  }
}
