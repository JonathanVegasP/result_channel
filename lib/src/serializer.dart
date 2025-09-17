import 'dart:typed_data';

abstract interface class Serializer {
  Uint8List serialize(Object? value);

  Object? deserialize(Uint8List value);
}
