import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'uint8list_converter.g.dart';

@JsonSerializable()
class Uint8ListConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(String? json) {
    if (json == null) return null;
    try {
      // base64 디코딩
      return base64.decode(json);
    } catch (e) {
      print('Error decoding base64 string: $e');
      return null;
    }
  }

  @override
  String? toJson(Uint8List? bytes) {
    if (bytes == null) return null;
    try {
      // base64 인코딩
      return base64.encode(bytes);
    } catch (e) {
      print('Error encoding to base64: $e');
      return null;
    }
  }
}
