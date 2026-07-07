import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/selectable_photo_card.dart';

/// 캐러셀 카드 1장의 이미지 소스 (로컬 파일 우선, 없으면 URL)
class PhotoCardCarouselItem {
  final File? imageFile;
  final String? imageUrl;

  const PhotoCardCarouselItem({this.imageFile, this.imageUrl});
}

/// 포토카드 가로 슬라이더 (앞면 선택/뒷면 선택 공용)
///
/// 중앙 카드를 강조하고 양옆 카드는 축소·반투명으로 미리 보여주며, 스와이프·좌우
/// 화살표·옆 카드 탭으로 넘긴다. 선택은 [selectedIndex]로 표시되고 탭 시 [onSelect]가
/// 호출된다. 장수 제한 없이 동작한다.
class PhotoCardCarousel extends StatefulWidget {
  final List<PhotoCardCarouselItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  final Color arrowBgColor;
  final Color arrowFgColor;
  final Color indicatorActiveColor;
  final Color indicatorInactiveColor;

  /// 슬라이더 전체 폭. null이면 부모 폭을 채운다 (Row 안에서는 반드시 지정).
  final double? width;
  final double viewportHeight;
  final double cardWidth;
  final double cardHeight;
  final double viewportFraction;
  final bool showCheckBadge;

  const PhotoCardCarousel({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.arrowBgColor,
    required this.arrowFgColor,
    required this.indicatorActiveColor,
    required this.indicatorInactiveColor,
    this.width,
    required this.viewportHeight,
    required this.cardWidth,
    required this.cardHeight,
    this.viewportFraction = 0.31,
    this.showCheckBadge = true,
  });

  @override
  State<PhotoCardCarousel> createState() => _PhotoCardCarouselState();
}

class _PhotoCardCarouselState extends State<PhotoCardCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = (widget.selectedIndex ?? 0).clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
    _pageController = PageController(viewportFraction: widget.viewportFraction, initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _moveToPage(int index) {
    SoundManager().playSound();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildArrowButton({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.25,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: widget.arrowBgColor.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: widget.arrowFgColor.withValues(alpha: 0.6), width: 1.5.w),
          ),
          child: Icon(icon, size: 48.sp, color: widget.arrowFgColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slider = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.viewportHeight,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                // 카드 글로우/그림자가 페이지 경계에서 잘리지 않도록
                clipBehavior: Clip.none,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      final page = _pageController.hasClients && _pageController.position.haveDimensions
                          ? _pageController.page ?? _currentPage.toDouble()
                          : _currentPage.toDouble();
                      final distance = (page - index).abs().clamp(0.0, 1.0);
                      return Center(
                        child: Transform.scale(
                          scale: 1.0 - distance * 0.12,
                          child: Opacity(opacity: 1.0 - distance * 0.15, child: child),
                        ),
                      );
                    },
                    child: SelectablePhotoCard(
                      width: widget.cardWidth,
                      height: widget.cardHeight,
                      index: index,
                      selectedIndex: widget.selectedIndex,
                      imageFile: item.imageFile,
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      showCheckBadge: widget.showCheckBadge,
                      onTap: () {
                        SoundManager().playSound();
                        if (index != _currentPage) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        }
                        widget.onSelect(index);
                      },
                    ),
                  );
                },
              ),
              if (widget.items.length > 1) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 28.w),
                    child: _buildArrowButton(
                      icon: Icons.chevron_left_rounded,
                      enabled: _currentPage > 0,
                      onTap: () => _moveToPage(_currentPage - 1),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 28.w),
                    child: _buildArrowButton(
                      icon: Icons.chevron_right_rounded,
                      enabled: _currentPage < widget.items.length - 1,
                      onTap: () => _moveToPage(_currentPage + 1),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 20.h),
        if (widget.items.length > 1 && widget.items.length <= 10)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: isActive ? 28.w : 12.w,
                height: 12.w,
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: isActive ? widget.indicatorActiveColor : widget.indicatorInactiveColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              );
            }),
          )
        else if (widget.items.length > 10)
          Text(
            '${_currentPage + 1} / ${widget.items.length}',
            style: TextStyle(fontSize: 24.sp, color: widget.indicatorActiveColor),
          ),
      ],
    );

    return widget.width == null ? slider : SizedBox(width: widget.width, child: slider);
  }
}
