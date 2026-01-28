import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

/// 이미지 선택 카드 위젯
/// 헤더, 로고, 버튼을 포함한 전체 카드 레이아웃
class ImageSelectionCard extends StatelessWidget {
  const ImageSelectionCard({
    super.key,
    required this.logoImageUrl,
    this.onSelectImageTap,
    this.headerTitle = '추천 이미지 선택',
    this.headerSubtitle = '이미지 선택 후 바로 출력',
    this.buttonText = '이미지 선택하기',
  });

  /// 로고 이미지 URL
  final String logoImageUrl;
  
  /// 이미지 선택 버튼 탭 콜백
  final VoidCallback? onSelectImageTap;
  
  /// 헤더 제목
  final String headerTitle;
  
  /// 헤더 부제목
  final String headerSubtitle;
  
  /// 버튼 텍스트
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더 섹션
        _buildHeader(context),
        // 메인 콘텐츠 (로고)
        Expanded(
          child: _buildMainContent(context),
        ),
        // 푸터 버튼
        _buildFooterButton(context),
      ],
    );
  }

  /// 헤더 섹션 빌드
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF4A9B8E), // teal-green 배경
      ),
      child: Column(
        children: [
          Text(
            headerTitle,
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w700,
              color: Colors.yellow,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            headerSubtitle,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8FA89F), // 회색-녹색
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 메인 콘텐츠 (로고) 빌드
  Widget _buildMainContent(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Container(
          width: 400.w,
          height: 400.w,
          margin: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: logoImageUrl.isNotEmpty
                ? Image.network(
                    logoImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderLogo();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                : _buildPlaceholderLogo(),
          ),
        ),
      ),
    );
  }

  /// 플레이스홀더 로고 빌드
  Widget _buildPlaceholderLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2D7A6F), // 어두운 teal
            const Color(0xFF4A9B8E), // 밝은 teal
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 노란색 삼각형과 원형 엠블럼을 간단히 표현
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1B5E4F),
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  'AG',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B5E4F),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 배너
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E4F),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'ANSAN GREENERS FC 2017',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // 팀 이름
            Text(
              'ANSAN',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            Text(
              'GREENERS FC',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 푸터 버튼 빌드
  Widget _buildFooterButton(BuildContext context) {
    final kioskColors = context.theme.extension<KioskColors>();
    final buttonColor = kioskColors?.buttonColor ?? const Color(0xFF1B5E4F);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: ElevatedButton(
        onPressed: onSelectImageTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

