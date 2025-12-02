import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/features/presentation/screens/widgets/widgets.dart';

/// 6가지 UI 기획안 선택을 위한 Provider
final selectedDesignProvider = StateProvider<int>((ref) => 0);

class ChoiceScreen extends ConsumerWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDesign = ref.watch(selectedDesignProvider);
    final kioskColors = context.kioskColors;
    final typography = context.typography;

    // 이미지 경로 (실제로는 API나 설정에서 가져와야 함)
    const frontImagePath = 'assets/images/print_loading.png';
    const fixedBackImagePath = 'assets/images/print_loading.png';
    const customBackImagePath = 'assets/images/print_loading.png';

    return Column(
        children: [
          // 기획안 선택 탭
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10.w,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: List.generate(6, (index) {
                  final designNames = [
                    '기획안 1: 카드 플립',
                    '기획안 2: 나란히 비교',
                    '기획안 3: 탭 전환',
                    '기획안 4: 카드 스택',
                    '기획안 5: 3D 회전',
                    '기획안 6: 회전목마',
                  ];
                  final isSelected = selectedDesign == index;
                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedDesignProvider.notifier).state = index;
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kioskColors.buttonColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? kioskColors.buttonColor
                              : Colors.grey[400]!,
                          width: 2.w,
                        ),
                      ),
                      child: Text(
                        designNames[index],
                        style: typography.kioskBody2B.copyWith(
                          color: isSelected
                              ? kioskColors.buttonTextColor
                              : Colors.grey[700],
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // 선택된 기획안 표시
          Expanded(
            child: _buildSelectedDesign(
              context,
              selectedDesign,
              frontImagePath: frontImagePath,
              fixedBackImagePath: fixedBackImagePath,
              customBackImagePath: customBackImagePath,
              onFixedSelected: () {
                // 고정 뒷면 선택 처리
                debugPrint('고정 뒷면 선택됨');
              },
              onCustomSelected: () {
                // 커스텀 뒷면 선택 처리
                debugPrint('커스텀 뒷면 선택됨');
              },
            ),
          ),
        ],
      );
  }

  Widget _buildSelectedDesign(
    BuildContext context,
    int designIndex, {
    required String? frontImagePath,
    required String? fixedBackImagePath,
    required String? customBackImagePath,
    required VoidCallback? onFixedSelected,
    required VoidCallback? onCustomSelected,
  }) {
    switch (designIndex) {
      case 0:
        return CardFlipChoiceWidget(
          frontImagePath: frontImagePath,
          fixedBackImagePath: fixedBackImagePath,
          customBackImagePath: customBackImagePath,
          onFixedSelected: onFixedSelected,
          onCustomSelected: onCustomSelected,
        );
      case 1:
        return SideBySideChoiceWidget(
          frontImagePath: frontImagePath,
          fixedBackImagePath: fixedBackImagePath,
          customBackImagePath: customBackImagePath,
          onFixedSelected: onFixedSelected,
          onCustomSelected: onCustomSelected,
        );
      case 2:
        return TabSwitchChoiceWidget(
          frontImagePath: frontImagePath,
          fixedBackImagePath: fixedBackImagePath,
          customBackImagePath: customBackImagePath,
          onFixedSelected: onFixedSelected,
          onCustomSelected: onCustomSelected,
        );
      case 3:
        return CardStackChoiceWidget(
          frontImagePath: frontImagePath,
          fixedBackImagePath: fixedBackImagePath,
          customBackImagePath: customBackImagePath,
          onFixedSelected: onFixedSelected,
          onCustomSelected: onCustomSelected,
        );
      case 4:
        return Rotate3DChoiceWidget(
          frontImagePath: frontImagePath,
          fixedBackImagePath: fixedBackImagePath,
          customBackImagePath: customBackImagePath,
          onFixedSelected: onFixedSelected,
          onCustomSelected: onCustomSelected,
        );
      case 5:
        return CarouselChoiceWidget(
          frontImagePath: frontImagePath,
          fixedBackImagePath: fixedBackImagePath,
          customBackImagePath: customBackImagePath,
          onFixedSelected: onFixedSelected,
          onCustomSelected: onCustomSelected,
          itemCount: 3,
        );
      default:
        return const Center(child: Text('알 수 없는 기획안'));
    }
  }
}
