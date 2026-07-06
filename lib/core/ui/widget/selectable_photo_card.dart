import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

/// 빈 이미지 플레이스홀더 (포토카드 공통)
class PhotoCardEmptyPlaceholder extends StatelessWidget {
  const PhotoCardEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 60.sp, color: Colors.grey[400]),
      ),
    );
  }
}

/// 포토카드 이미지 프레임 (라운드 + 테두리/그림자 + 로딩/에러 처리 공통)
///
/// 뒷면 미리보기(PaymentScreen)와 앞면 선택(FrontPhotoSelectScreen)에서 공용 사용.
/// [imageFile]이 있으면 로컬 파일을 우선 사용하고, 없으면 [imageUrl]로 네트워크 로드한다.
class PhotoCardFrame extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final List<BoxShadow>? boxShadow;
  final bool hasBorder;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PhotoCardFrame({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.boxShadow,
    this.hasBorder = false,
    this.width,
    this.height,
    this.fit = BoxFit.fitHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: hasBorder ? Border.all(color: Colors.white, width: 1.w) : null,
        boxShadow: hasBorder
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 4.r,
                  spreadRadius: 1.r,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 12.r,
                  spreadRadius: 3.r,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 28.r,
                  spreadRadius: 6.r,
                ),
              ]
            : boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: fit,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => const PhotoCardEmptyPlaceholder(),
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return const PhotoCardEmptyPlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      alignment: Alignment.center,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const PhotoCardEmptyPlaceholder(),
    );
  }
}

/// 선택형 포토카드 (시안 6: 미선택 카드 축소 + 반투명 애니메이션)
///
/// [selectedIndex]가 null이면 아무것도 선택되지 않은 상태로 모두 원본 크기,
/// 선택이 생기면 선택 카드는 강조 그림자, 나머지는 축소/반투명 처리된다.
class SelectablePhotoCard extends StatelessWidget {
  final int index;
  final int? selectedIndex;
  final String? imageUrl;
  final File? imageFile;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SelectablePhotoCard({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.imageUrl,
    this.imageFile,
    this.width,
    this.height,
    this.fit = BoxFit.fitHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final kioskColors = Theme.of(context).extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);

    // 선택되지 않은 경우 크기를 0.85배로 축소
    final scale = selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.85);
    final opacity = selectedIndex == null ? 1.0 : (isSelected ? 1.0 : 0.6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: PhotoCardFrame(
            width: width,
            height: height,
            fit: fit,
            imageUrl: imageUrl,
            imageFile: imageFile,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.4),
                      blurRadius: 12.r,
                      spreadRadius: 2.r,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
