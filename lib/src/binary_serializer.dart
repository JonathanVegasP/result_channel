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

  @pragma('vm:prefer-inline')
  static void _writeSize(Writer writer, int value) {
    switch (value) {
      case < _MAX_BYTES:
        writer.putByte(value);
      case <= _MAX_CHAR_VALUE:
        writer.putByte(_MAX_BYTES);
        writer.putChar(value);
      default:
        writer.putByte(_MAX_CHAR);
        writer.putInt(value);
    }
  }

  @pragma('vm:prefer-inline')
  static void _append(Writer writer, dynamic value) {
    switch (value) {
      case Null _:
        writer.putByte(_NULL);
        break;
      case bool v:
        writer.putByte(v ? _TRUE : _FALSE);
        break;
      case int v:
        if ((v >> 31) == (v >> 63)) {
          writer.putByte(_INT);
          writer.putInt(v);
        } else {
          writer.putByte(_LONG);
          writer.putLong(v);
        }
        break;
      case double v:
        writer.putByte(_DOUBLE);
        writer.putDouble(v);
        break;
      case String v:
        writer.putByte(_STRING);
        final length = v.length;
        final bytes = Uint8List(length);
        Uint8List? utf8Bytes;
        var utf8Offset = 0;

        for (var i = 0; i < length; i++) {
          final char = v.codeUnitAt(i);
          if (char <= 0x7F) {
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
          _writeSize(writer, length);
          writer.putUint8List(bytes);
        }
        break;
      case Uint8List v:
        writer.putByte(_BYTE_ARRAY);
        _writeSize(writer, v.length);
        writer.putUint8List(v);
        break;
      case Int32List v:
        writer.putByte(_INT_ARRAY);
        _writeSize(writer, v.length);
        writer.putInt32List(v);
        break;
      case Int64List v:
        writer.putByte(_LONG_ARRAY);
        _writeSize(writer, v.length);
        writer.putInt64List(v);
        break;
      case Float32List v:
        writer.putByte(_FLOAT_ARRAY);
        _writeSize(writer, v.length);
        writer.putFloat32List(v);
        break;
      case Float64List v:
        writer.putByte(_DOUBLE_ARRAY);
        _writeSize(writer, v.length);
        writer.putFloat64List(v);
        break;
      case List v:
        writer.putByte(_LIST);
        _writeSize(writer, v.length);
        for (final item in v) {
          _append(writer, item);
        }
        break;
      case Set v:
        writer.putByte(_SET);
        _writeSize(writer, v.length);
        for (final item in v) {
          _append(writer, item);
        }
        break;
      case Map v:
        writer.putByte(_MAP);
        _writeSize(writer, v.length);
        final entries = v.entries;
        for (final item in entries) {
          _append(writer, item.key);
          _append(writer, item.value);
        }
        break;
      default:
        throw ArgumentError(
          'Unsupported type for serialization: ${value.runtimeType}',
        );
    }
  }

  @pragma('vm:prefer-inline')
  static int _readSize(BinaryReader reader) {
    final typeByte = reader.readByte();
    return switch (typeByte) {
      < _MAX_BYTES => typeByte,
      == _MAX_BYTES => reader.readChar(),
      _ => reader.readInt(),
    };
  }

  @pragma('vm:prefer-inline')
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
