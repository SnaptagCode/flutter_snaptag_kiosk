import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/widgets/back_photo_images.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/widgets/selection_effects.dart';

/// 출력 스타일 선택 카드 2장 — 풀이미지/라벨 (한화 전용).
///
/// 미리보기는 서버 호출 없이 원본 이미지로 클라이언트에서 합성한다:
/// 라벨판은 상/하단 이벤트명·날짜 밴드 근사 렌더링, 풀이미지판은 원본 cover.
class BackPhotoStyleCards extends ConsumerWidget {
  const BackPhotoStyleCards({super.key, required this.card});

  final NominatedBackPhotoCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 풀이미지가 기본 선택 — 전송값 보정(effectiveLayoutType)과 같은 규칙
    final layout = ref.watch(backPhotoTypeProvider)?.effectiveLayoutType(isHwe: true) ?? BackPhotoLayoutType.full;
    final selectedStyleIndex = layout == BackPhotoLayoutType.full ? 1 : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStyleCard(
          context,
          index: 1,
          selectedIndex: selectedStyleIndex,
          card: _buildFullPreviewCard(),
          onTap: () => ref.read(backPhotoTypeProvider.notifier).selectLayout(BackPhotoLayoutType.full),
        ),
        SizedBox(width: 100.w),
        _buildStyleCard(
          context,
          index: 0,
          selectedIndex: selectedStyleIndex,
          card: _buildLabeledPreviewCard(context, ref),
          onTap: () => ref.read(backPhotoTypeProvider.notifier).selectLayout(BackPhotoLayoutType.labeled),
        ),
      ],
    );
  }

  /// 실제 포토카드 비율에 맞는 UI 크기 조정
  /// 전체크기 650*1023 상단 라벨위치 y: 0~80 / 하단 라벨 위치 y: 943~1023 (650 * 80)
  Widget _buildLabeledPreviewCard(BuildContext context, WidgetRef ref) {
    final kiosk = ref.read(kioskInfoServiceProvider);
    final eventName = kiosk?.printedEventName ?? '';
    final now = DateTime.now();
    final dateText = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    final fontFamily = _labelFontFamily(context, ref);

    final double cardHeight = 355.h;
    final double bandHeight = cardHeight * 80 / 1023;

    return Container(
      width: 226.w,
      height: cardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Container(
            height: bandHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              eventName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: bandHeight * 0.5,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CoverNetworkImage(card.originUrl),
            ),
          ),
          Container(
            height: bandHeight,
            alignment: Alignment.center,
            child: Text(
              dateText,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: bandHeight * 0.45,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 포토카드 라벨 글꼴: 한화(HWEG) HanwhaEagles-Regular
  /// 일본어 KeinanMugimaruJP, 기본 Cafe24Ssurround v2.
  String _labelFontFamily(BuildContext context, WidgetRef ref) {
    if (ref.read(kioskInfoServiceProvider)?.isHwe ?? false) return 'Hanwha';
    if (context.locale.languageCode == 'ja') return 'KeinanMugimaruJP';
    return 'Cafe24Ssurround2';
  }

  Widget _buildFullPreviewCard() {
    return Container(
      width: 226.w,
      height: 355.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
      child: CoverNetworkImage(card.originUrl),
    );
  }

  Widget _buildStyleCard(
    BuildContext context, {
    required int index,
    required int selectedIndex,
    required Widget card,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    // 카드 모서리(10.r)에 링 두께와 간격을 더해야 링이 카드와 동심원으로 보인다.
    final outerRadius = BorderRadius.circular(10.r + SelectionRing.inset);

    return GestureDetector(
      onTap: onTap,
      child: SelectionTransition(
        isSelected: isSelected,
        unselectedScale: 0.92,
        unselectedOpacity: 0.68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SelectionRing(
              isSelected: isSelected,
              color: buttonColor,
              borderRadius: outerRadius,
              // 비선택 카드도 배경 사진 위에서 떠 보이도록 옅은 그림자를 남긴다.
              restShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r, offset: Offset(0, 2.h)),
              ],
              child: card,
            ),
            Positioned(
              right: 12.w,
              bottom: 12.h,
              child: SelectionCheckBadge(
                visible: isSelected,
                size: 40.r,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
