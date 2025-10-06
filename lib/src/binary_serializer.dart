import 'dart:convert';
import 'dart:typed_data';

import 'binary_reader.dart';
import 'binary_writer.dart';

abstract final class BinarySerializer {
  static const int _null = 0x00;
  static const int _true = 0x01;
  static const int _false = 0x02;
  static const int _int = 0x03;
  static const int _long = 0x04;
  static const int _double = 0x05;
  static const int _string = 0x06;
  static const int _byteArray = 0x07;
  static const int _intArray = 0x08;
  static const int _longArray = 0x09;
  static const int _floatArray = 0x0A;
  static const int _doubleArray = 0x0B;
  static const int _list = 0x0C;
  static const int _set = 0x0D;
  static const int _map = 0x0E;

  static const int _maxByte = 0xFE;
  static const int _maxChar = 0xFF;
  static const int _maxCharValue = 0xFFFF;

  static void _writeSize(BinaryWriter writer, int value) {
    switch (value) {
      case < _maxByte:
        writer.putByte(value);
      case <= _maxCharValue:
        writer.putByte(_maxByte);
        writer.putChar(value);
      default:
        writer.putByte(_maxChar);
        writer.putInt(value);
    }
  }

  static void _append(BinaryWriter writer, dynamic value) {
    switch (value) {
      case Null _:
        writer.putByte(_null);
        break;
      case bool v:
        writer.putByte(v ? _true : _false);
        break;
      case int v:
        if ((v >> 31) == (v >> 63)) {
          writer.putByte(_int);
          writer.putInt(v);
        } else {
          writer.putByte(_long);
          writer.putLong(v);
        }
        break;
      case double v:
        writer.putByte(_double);
        writer.putDouble(v);
        break;
      case String v:
        writer.putByte(_string);
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
        writer.putByte(_byteArray);
        _writeSize(writer, v.length);
        writer.putUint8List(v);
        break;
      case Int32List v:
        writer.putByte(_intArray);
        _writeSize(writer, v.length);
        writer.putInt32List(v);
        break;
      case Int64List v:
        writer.putByte(_longArray);
        _writeSize(writer, v.length);
        writer.putInt64List(v);
        break;
      case Float32List v:
        writer.putByte(_floatArray);
        _writeSize(writer, v.length);
        writer.putFloat32List(v);
        break;
      case Float64List v:
        writer.putByte(_doubleArray);
        _writeSize(writer, v.length);
        writer.putFloat64List(v);
        break;
      case List v:
        writer.putByte(_list);
        _writeSize(writer, v.length);
        for (final item in v) {
          _append(writer, item);
        }
        break;
      case Set v:
        writer.putByte(_set);
        _writeSize(writer, v.length);
        for (final item in v) {
          _append(writer, item);
        }
        break;
      case Map v:
        writer.putByte(_map);
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

  static int _readSize(BinaryReader reader) {
    final typeByte = reader.getByte();
    return switch (typeByte) {
      < _maxByte => typeByte,
      == _maxByte => reader.getChar(),
      _ => reader.getInt(),
    };
  }

  static Object? _read(BinaryReader reader) {
    final type = reader.getByte();
    switch (type) {
      case _null:
        return null;
      case _true:
        return true;
      case _false:
        return false;
      case _int:
        return reader.getInt();
      case _long:
        return reader.getLong();
      case _double:
        return reader.getDouble();
      case _string:
        final bytes = reader.getUint8List(_readSize(reader));
        return utf8.decoder.convert(bytes);
      case _byteArray:
        return reader.getUint8List(_readSize(reader));
      case _intArray:
        return reader.getInt32List(_readSize(reader));
      case _longArray:
        return reader.getInt64List(_readSize(reader));
      case _floatArray:
        return reader.getFloat32List(_readSize(reader));
      case _doubleArray:
        return reader.getFloat64List(_readSize(reader));
      case _list:
        final size = _readSize(reader);
        final list = List<Object?>.filled(size, null);
        for (int i = 0; i < size; i++) {
          list[i] = _read(reader);
        }
        return list;
      case _set:
        final size = _readSize(reader);
        final set = <Object?>{};
        for (int i = 0; i < size; i++) {
          set.add(_read(reader));
        }
        return set;
      case _map:
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

  static Uint8List serialize(Object? value) {
    final writer = BinaryWriter();
    _append(writer, value);
    return writer.toUint8List();
  }

  static Object? deserialize(Uint8List value) {
    final reader = BinaryReader(value);
    return _read(reader);
  }
}
