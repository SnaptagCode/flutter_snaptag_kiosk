import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 뒷면 이미지 부재/로딩 실패 시 회색 플레이스홀더.
class BackPhotoPlaceholder extends StatelessWidget {
  const BackPhotoPlaceholder({super.key});

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

/// cover 핏 네트워크 이미지 — 페이드인, 로딩 인디케이터, 실패 시 플레이스홀더.
class CoverNetworkImage extends StatelessWidget {
  const CoverNetworkImage(this.imageUrl, {super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
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
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => const BackPhotoPlaceholder(),
    );
  }
}
