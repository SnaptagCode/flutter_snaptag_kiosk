import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'nominated_photo.freezed.dart';
part 'nominated_photo.g.dart';

@freezed
class NominatedPhoto with _$NominatedPhoto {
  const factory NominatedPhoto({
    required int id,
    required int embeddingProductId,
    required int code,
    required String originUrl,
    required String embedUrl,
    required int selectionWeight,
    required bool isWin,
    @JsonKey(ignore: true) File? embedImage, // JSON 직렬화 제외
  }) = _NominatedPhoto;

  /// ✅ `getter` 추가를 위해 private constructor 필요
  const NominatedPhoto._();
  factory NominatedPhoto.fromJson(Map<String, dynamic> json) => _$NominatedPhotoFromJson(json);

  /// ✅ embedImageData가 `null`이면 에러 발생
  File get safeEmbedImage {
    if (embedImage == null) {
      throw Exception('embedImageData is required but was accessed as null!');
    }
    return embedImage!;
  }
}

// '{id}_{code}_{embeddingProductId}_{selectedWeight}_{isWin}.확장자' 형식
// - isWin 은 true 일 때 1, false 일 때 0
extension NominatedPhotoExt on NominatedPhoto {
  String get getFileName => '${id}_${code}_${embeddingProductId}_${selectionWeight}_${isWin ? 1 : 0}';
}

extension NominatedPhotoStringExt on String {
  NominatedPhoto? get getNominatedPhotoForTest {
    // Remove file extension if present
    final fileName = contains('.') ? split('.').first : this;

    // Split the string into parts
    final parts = fileName.split('_');
    if (parts.length != 5) {
      return null;
    }

    // Parse the parts into their respective types
    final id = int.tryParse(parts[0]);
    final code = int.tryParse(parts[1]);
    final embeddingProductId = int.tryParse(parts[2]);
    final weight = int.tryParse(parts[3]);
    final isWin = parts[4] == '1';

    // Check for null values
    if (id == null || code == null || embeddingProductId == null || weight == null) {
      return null;
    }

    // Create and return the NominatedPhoto object
    return NominatedPhoto(
      id: id,
      code: code,
      embeddingProductId: embeddingProductId,
      selectionWeight: weight,
      isWin: isWin,
      originUrl: '',
      embedUrl: '',
      embedImage: File(fileName),
    );
  }
}
