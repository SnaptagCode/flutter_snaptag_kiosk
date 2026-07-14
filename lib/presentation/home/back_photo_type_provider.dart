import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 뒷면 이미지 타입
enum BackPhotoType {
  /// 고정 뒷면 이미지 (추천 이미지)
  fixed,

  /// 커스텀 뒷면 이미지 (사용자 업로드)
  custom,
}

/// 뒷면 출력 스타일 (JKLI-214)
enum BackPhotoLayoutType {
  /// 상/하단 이벤트명·날짜 라벨 포함 — 기존 출력과 동일
  labeled,

  /// 라벨 없이 이미지가 카드 전체를 채움 (임베딩은 유지)
  full,
}

extension BackPhotoLayoutTypeX on BackPhotoLayoutType {
  /// POST /v1/qr/back-photo-nominated 의 imageType 전송 값 (대문자)
  ///
  /// 라벨 이미지는 서버가 이벤트명·날짜 밴드를 합성한 것이라 FORMATTED,
  /// 풀이미지는 원본 그대로라 ORIGIN 이다.
  String get imageType => this == BackPhotoLayoutType.full ? 'ORIGIN' : 'FORMATTED';
}

/// 뒷면 이미지 선택 상태
class BackPhotoSelection {
  final BackPhotoType type;
  final int? fixedIndex; // 고정 이미지인 경우 선택된 인덱스 (0 또는 1)

  /// 선택된 출력 스타일. null = 미선택(스타일 UI 미노출 포함) —
  /// 결제 시 [effectiveLayoutType]으로 업체별 기본값이 보정된다.
  final BackPhotoLayoutType? layoutType;

  const BackPhotoSelection({
    required this.type,
    this.fixedIndex,
    this.layoutType,
  });

  /// 고정 뒷면 이미지 선택
  factory BackPhotoSelection.fixed(int index) {
    return BackPhotoSelection(
      type: BackPhotoType.fixed,
      fixedIndex: index,
    );
  }

  /// 커스텀 뒷면 이미지 선택
  factory BackPhotoSelection.custom() {
    return BackPhotoSelection(
      type: BackPhotoType.custom,
      fixedIndex: null,
    );
  }

  /// 결제 시 실제 적용될 출력 스타일 — 화면 하이라이트와 imageType 전송이 공유하는 규칙 (JKLI-214).
  ///
  /// 미선택(null)이면 한화는 풀이미지(ORIGIN), 그 외 업체는 스타일 UI가 없으므로
  /// 라벨(FORMATTED = 기존 출력과 동일)로 보정한다.
  BackPhotoLayoutType effectiveLayoutType({required bool isHwe}) =>
      layoutType ?? (isHwe ? BackPhotoLayoutType.full : BackPhotoLayoutType.labeled);
}

class BackPhotoTypeNotifier extends StateNotifier<BackPhotoSelection?> {
  BackPhotoTypeNotifier() : super(null);

  /// 고정 뒷면 이미지 선택 (인덱스 지정) — 재선택 시 layoutType도 초기화된다
  void selectFixed(int index) {
    state = BackPhotoSelection.fixed(index);
  }

  /// 커스텀 뒷면 이미지 선택
  void selectCustom() {
    state = BackPhotoSelection.custom();
  }

  /// 출력 스타일 선택 (고정 뒷면 전용)
  void selectLayout(BackPhotoLayoutType layout) {
    final current = state;
    if (current == null) return;
    state = BackPhotoSelection(
      type: current.type,
      fixedIndex: current.fixedIndex,
      layoutType: layout,
    );
  }

  /// 선택 초기화
  void reset() => state = null;
}

final backPhotoTypeProvider = StateNotifierProvider<BackPhotoTypeNotifier, BackPhotoSelection?>(
  (ref) => BackPhotoTypeNotifier(),
);
