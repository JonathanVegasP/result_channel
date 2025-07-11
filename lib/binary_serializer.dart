import 'dart:convert';
import 'dart:typed_data';

import 'binary_reader.dart';
import 'binary_writer.dart';
import 'serializer.dart';
import 'writer.dart';

class BinarySerializer implements Serializer<Uint8List> {
  const BinarySerializer();

  static const int _NULL = 0x00;
  static const int _TRUE = 0x01;
  static const int _FALSE = 0x02;
  static const int _INT = 0x03;
  static const int _LONG = 0x04;
  static const int _DOUBLE = 0x05;
  static const int _STRING = 0x06;
  static const int _BYTE_ARRAY = 0x07;
  static const int _INT_ARRAY = 0x08;
  static const int _LONG_ARRAY = 0x09;
  static const int _FLOAT_ARRAY = 0x0A;
  static const int _DOUBLE_ARRAY = 0x0B;
  static const int _LIST = 0x0C;
  static const int _SET = 0x0D;
  static const int _MAP = 0x0E;

  static const int _MAX_BYTES = 0xFE;
  static const int _MAX_CHAR = 0xFF;
  static const int _MAX_CHAR_VALUE = 0xFFFF;

  @pragma("vm:prefer-inline")
  static void _writeSize(Writer writer, int value) {
    if (value < _MAX_BYTES) {
      writer.putByte(value);
    } else if (value <= _MAX_CHAR_VALUE) {
      writer.putByte(_MAX_BYTES);
      writer.putChar(value);
    } else {
      writer.putByte(_MAX_CHAR);
      writer.putInt(value);
    }
  }

  @pragma("vm:prefer-inline")
  static void _append(Writer writer, dynamic value) {
    if (value == null) {
      writer.putByte(_NULL);
    } else if (value is bool) {
      writer.putByte(value ? _TRUE : _FALSE);
    } else if (value is int) {
      // Dart's int can be 64-bit, Kotlin's int is 32-bit.
      // We need to decide if we want to serialize as INT (32-bit) or LONG (64-bit).
      // Based on Kotlin's `is Byte, is Short, is Int` for INT,
      // let's assume Dart ints that fit in 32-bit signed int go to INT,
      // larger ones go to LONG.
      if (value >= -0x80000000 && value <= 0x7FFFFFFF) {
        // Fits in signed 32-bit int
        writer.putByte(_INT);
        writer.putInt(value);
      } else {
        writer.putByte(_LONG);
        writer.putLong(value);
      }
    } else if (value is double) {
      writer.putByte(_DOUBLE);
      writer.putDouble(value);
    } else if (value is String) {
      writer.putByte(_STRING);

      final length = value.length;
      Uint8List bytes = Uint8List(length);
      Uint8List? utf8Bytes;
      int utf8Offset = 0;

      for (int i = 0; i < length; i += 1) {
        final int char = value.codeUnitAt(i);

        if (char <= 0x7f) {
          bytes[i] = char;
        } else {
          utf8Bytes = utf8.encode(value.substring(i));
          utf8Offset = i;
          break;
        }
      }

      if (utf8Bytes != null) {
        _writeSize(writer, utf8Offset + utf8Bytes.length);
        writer.putUint8List(Uint8List.sublistView(bytes, 0, utf8Offset));
        writer.putUint8List(utf8Bytes);
      } else {
        _writeSize(writer, bytes.length);
        writer.putUint8List(bytes);
      }
    } else if (value is Uint8List) {
      writer.putByte(_BYTE_ARRAY);
      _writeSize(writer, value.length);
      writer.putUint8List(value);
    } else if (value is Int32List) {
      writer.putByte(_INT_ARRAY);
      _writeSize(writer, value.length);
      writer.putInt32List(value);
    } else if (value is Int64List) {
      writer.putByte(_LONG_ARRAY);
      _writeSize(writer, value.length);
      writer.putInt64List(value);
    } else if (value is Float32List) {
      writer.putByte(_FLOAT_ARRAY);
      _writeSize(writer, value.length);
      writer.putFloat32List(value);
    } else if (value is Float64List) {
      writer.putByte(_DOUBLE_ARRAY);
      _writeSize(writer, value.length);
      writer.putFloat64List(value);
    } else if (value is List) {
      writer.putByte(_LIST);
      _writeSize(writer, value.length);
      for (final item in value) {
        _append(writer, item);
      }
    } else if (value is Set) {
      writer.putByte(_SET);
      _writeSize(writer, value.length);
      for (final item in value) {
        _append(writer, item);
      }
    } else if (value is Map) {
      writer.putByte(_MAP);
      _writeSize(writer, value.length);
      final entries = value.entries;
      for (final entry in entries) {
        _append(writer, entry.key);
        _append(writer, entry.value);
      }
    } else {
      throw ArgumentError(
        'Unsupported type for serialization: ${value.runtimeType}',
      );
    }
  }

  @pragma("vm:prefer-inline")
  static int _readSize(BinaryReader reader) {
    final typeByte = reader.readByte();
    if (typeByte < _MAX_BYTES) {
      return typeByte;
    } else if (typeByte == _MAX_BYTES) {
      return reader.readChar();
    } else {
      return reader.readInt();
    }
  }

  @pragma("vm:prefer-inline")
  static Object? _read(BinaryReader reader) {
    final type = reader.readByte();
    switch (type) {
      case _NULL:
        return null;
      case _TRUE:
        return true;
      case _FALSE:
        return false;
      case _INT:
        return reader.readInt();
      case _LONG:
        return reader.readLong();
      case _DOUBLE:
        return reader.readDouble();
      case _STRING:
        return reader.readString(_readSize(reader));
      case _BYTE_ARRAY:
        return reader.readUint8List(_readSize(reader));
      case _INT_ARRAY:
        return reader.readInt32List(_readSize(reader));
      case _LONG_ARRAY:
        return reader.readInt64List(_readSize(reader));
      case _FLOAT_ARRAY:
        return reader.readFloat32List(_readSize(reader));
      case _DOUBLE_ARRAY:
        return reader.readFloat64List(_readSize(reader));
      case _LIST:
        final size = _readSize(reader);
        final list = List<Object?>.filled(size, null);
        for (int i = 0; i < size; i++) {
          list[i] = _read(reader);
        }
        return list;
      case _SET:
        final size = _readSize(reader);
        final set = <Object?>{};
        for (int i = 0; i < size; i++) {
          set.add(_read(reader));
        }
        return set;
      case _MAP:
        final size = _readSize(reader);
        final map = <Object?, Object?>{};
        for (int i = 0; i < size; i++) {
          final key = _read(reader);
          final value = _read(reader);
          map[key] = value;
        }
        return map;
      default:
        throw ArgumentError('Message corrupted');
    }
  }

  @pragma('vm:prefer-inline')
  @override
  Uint8List serialize(Object? value) {
    final writer = BinaryWriter();
    _append(writer, value);
    return writer.toUint8List();
  }

  @pragma('vm:prefer-inline')
  @override
  Object? deserialize(Uint8List value) {
    final reader = BinaryReader(value);
    return _read(reader);
  }
}
