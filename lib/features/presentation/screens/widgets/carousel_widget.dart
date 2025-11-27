import 'dart:math' as math;
import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  final int itemCount; // 회전목마 아이템 개수

  const CarouselWidget({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotateCarousel() {
    if (_controller.isAnimating) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.itemCount;
    });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _rotateCarousel,
      child: SizedBox(
        height: 400,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: List.generate(widget.itemCount, (index) {
                return _buildCarouselItem(index);
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarouselItem(int index) {
    final itemCount = widget.itemCount;

    // 현재 인덱스로부터의 상대적 위치 계산
    int relativePosition = (index - _currentIndex) % itemCount;
    if (relativePosition < 0) relativePosition += itemCount;

    // 애니메이션 진행에 따른 위치 조정
    final animatedPosition = relativePosition - _animation.value;

    // 원형 배치를 위한 각도 계산 (360도를 아이템 개수로 나눔)
    final angle = (animatedPosition * 2 * math.pi) / itemCount;

    // 중심 아이템 판단 (애니메이션 중에는 보간)
    final distanceFromCenter = (animatedPosition % itemCount).abs();
    final normalizedDistance = distanceFromCenter > itemCount / 2 ? itemCount - distanceFromCenter : distanceFromCenter;

    // Scale 계산 (중심: 1.0, 나머지: 0.7)
    final scale = 0.7 + (0.3 * (1 - (normalizedDistance / (itemCount / 2)).clamp(0.0, 1.0)));

    // 투명도 계산 (중심: 1.0, 나머지: 0.5)
    final opacity = normalizedDistance < 0.5 ? 1.0 : 0.5;

    // 원형 배치를 위한 X, Y 오프셋 계산
    final radius = 150.0; // 회전목마 반지름
    final xOffset = math.sin(angle) * radius;
    final yOffset = (math.cos(angle) - 1) * 50; // 약간의 Y축 변화로 깊이감 표현

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 100 + xOffset,
      top: 100 + yOffset,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 200,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: normalizedDistance < 0.5
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: _buildItemContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildItemContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/print_loading.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
