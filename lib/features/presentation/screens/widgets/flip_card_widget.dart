import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FlipCardWidget extends StatefulWidget {
  const FlipCardWidget({super.key});

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    // 처음에 뒷면을 보여주기 위해 180도 회전 상태로 설정 (0.5 = 180도)
    _controller.value = 0.5;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;

    // 매번 360도 회전 (항상 0.0에서 시작해서 1.0까지)
    // 현재 값이 0.5면 0.0으로 리셋 후 1.0까지 (360도)
    // 현재 값이 0.0 또는 1.0이면 0.0에서 시작해서 1.0까지 (360도)
    _controller.value = 0.0;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // 360도 회전 (2π 라디안)
          final rotationAngle = _animation.value * 2 * 3.14159;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 원근감 설정
              ..rotateY(rotationAngle), // Y축 중심으로 회전
            child: _animation.value >= 0.5
                ? _buildBackCard()
                : _buildFrontCard(),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: 400.w,
      height: 560.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20.w,
            spreadRadius: 4.w,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.asset(
          'assets/images/print_loading.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: 400.w,
      height: 560.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20.w,
            spreadRadius: 4.w,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.asset(
          'assets/images/print_loading.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

