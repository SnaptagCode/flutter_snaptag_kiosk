import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class AuthCodeKeypad extends StatefulWidget {
  const AuthCodeKeypad({
    super.key,
    required this.onCompleted,
    required this.mode,
  });

  /// 코드 입력이 완료되었을 때 실행할 콜백 함수
  final Function(String code) onCompleted;
  final ModeType mode;

  @override
  State<AuthCodeKeypad> createState() => _AuthCodeKeypadState();
}

class _AuthCodeKeypadState extends State<AuthCodeKeypad> {
  //static const int maxLength = 4; // 최대 입력 가능 길이
  late final int maxLength;
  String _code = ''; // 입력된 코드 상태
  bool _isObscured = false; //비밀번호 가림 설정 - false 도입시 위치 옮기기 필요 todo

  @override
  void initState() {
    super.initState();
    maxLength = (widget.mode == ModeType.admin) ? 6 : 4;
    _isObscured = (widget.mode == ModeType.admin) ? true : false;
  }

  /// 숫자 추가
  void _addNumber(String number) {
    if (_code.length < maxLength) {
      setState(() {
        _code += number;
      });
    }
  }

  /// 마지막 입력 삭제
  void _removeLast() {
    if (_code.isNotEmpty) {
      setState(() {
        _code = _code.substring(0, _code.length - 1);
      });
    }
  }

  /// 입력 초기화
  void _clear() {
    setState(() {
      _code = '';
    });
  }

  /// 입력 완료 (길이가 `maxLength`인 경우)
  void _onComplete() {
    if (_code.isNotEmpty) {
      widget.onCompleted(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _InputDisplay(code: _code, onClear: _clear, isObscured: _isObscured),
        SizedBox(height: 30.h),
        _NumericPad(
          onNumberPressed: _addNumber,
          onDeletePressed: _removeLast,
          onConfirmPressed: _onComplete,
        ),
      ],
    );
  }
}

/// 코드 입력 UI
class _InputDisplay extends StatelessWidget {
  const _InputDisplay({
    required this.code,
    required this.onClear,
    required this.isObscured,
  });

  final String code;
  final VoidCallback onClear;
  final bool isObscured;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 478.w,
      height: 86.h,
      decoration: context.keypadDisplayDecoration,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Center(
            child: Text(
              isObscured && ModeType.admin == ModeType.admin ? '*' * code.length : code,
              textAlign: TextAlign.center,
              style: context.typography.kioskInput1B.copyWith(color: Colors.black),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onClear,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Image.asset(
                  SnaptagImages.close,
                  width: 38.w,
                  height: 38.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 숫자 패드 UI
class _NumericPad extends StatelessWidget {
  const _NumericPad({
    required this.onNumberPressed,
    required this.onDeletePressed,
    required this.onConfirmPressed,
  });

  final Function(String number) onNumberPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int row = 0; row < 4; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int col = 0; col < 3; col++) ...[
                _buildGridItem(context, row * 3 + col),
                if (col < 2) SizedBox(width: 10.w), // 컬럼 간격 추가
              ],
            ],
          ),
          if (row < 3) SizedBox(height: 10.h), // 로우 간격 추가
        ],
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, int index) {
    if (index == 9) {
      return ElevatedButton(
        //style: context.keypadNumberStyle,
        style: context.keypadBackStyle,
        onPressed: () async {
          await SoundManager().playSound();
          onDeletePressed();
        },
        child: SizedBox(
          width: 60.w,
          height: 60.h,
          child: Image.asset(SnaptagImages.arrowBack),
        ),
      );
    }
    if (index == 10) {
      return ElevatedButton(
        style: context.keypadNumberStyle,
        onPressed: () async {
          await SoundManager().playSound();
          onNumberPressed('0');
        },
        child: const Text('0'),
      );
    }
    if (index == 11) {
      return ElevatedButton(
        style: context.keypadCompleteStyle,
        onPressed: () async {
          await SoundManager().playSound();
          onConfirmPressed();
        },
        child: Text(LocaleKeys.sub01_btn_done.tr()),
      );
    }
    return ElevatedButton(
      style: context.keypadNumberStyle,
      onPressed: () async {
        await SoundManager().playSound();
        onNumberPressed('${index + 1}');
      },
      child: Text('${index + 1}'),
    );
  }
}
