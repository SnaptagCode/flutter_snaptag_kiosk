import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({
    super.key,
    this.contentPadding,
  });

  /// The ListTiles tile's internal padding.
  ///
  /// If null, `EdgeInsets.symmetric(horizontal: 16.0)` is used.
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale currentLocale = Localizations.localeOf(context);

    // 지원하는 언어 목록 정의
    final List<LocaleOption> localeOptions = [
      LocaleOption(
        locale: const Locale('ko', 'KR'),
        name: '한국어',
        flag: 'assets/icons/flag_kr.svg',
      ),
      LocaleOption(
        locale: const Locale('en', 'US'),
        name: 'English',
        flag: 'assets/icons/flag_us.svg',
      ),
      LocaleOption(
        locale: const Locale('ja', 'JP'),
        name: '日本語',
        flag: 'assets/icons/flag_jp.svg',
        fontFamily: 'PrentendardJP',
      ),
    ];

    // 현재 선택된 언어 옵션 찾기
    final LocaleOption selectedOption = localeOptions.firstWhere(
      (option) => option.locale.languageCode == currentLocale.languageCode,
      orElse: () => localeOptions.first,
    );

    return PopupMenuButton<Locale>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 0),
      position: PopupMenuPosition.under,
      onSelected: (Locale locale) {
        EasyLocalization.of(context)!.setLocale(locale);
      },
      color: Colors.white,
      itemBuilder: (BuildContext context) => <PopupMenuItem<Locale>>[
        for (final option in localeOptions)
          PopupMenuItem<Locale>(
            value: option.locale,
            height: 44.h,
            child: MenuWidget(
              option: option,
              isSelected: false,
            ),
          )
      ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: Colors.white,
        ),
        height: 44.h,
        width: 162.w,
        padding: EdgeInsets.only(top: 8.r, left: 12.r, right: 10.r, bottom: 8.r),
        child: MenuWidget(
          option: selectedOption,
          isSelected: true,
        ),
      ),
    );
  }
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({
    super.key,
    required this.option,
    required this.isSelected,
  });

  final LocaleOption option;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              option.flag,
              width: 32.w,
              height: 24.h,
            ),
            SizedBox(width: 8.w),
            Text(
              option.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontFamily: option.fontFamily,
              ),
            ),
          ],
        ),
        if (isSelected) ...[
          SvgPicture.asset(
            'assets/icons/arrow_down.svg',
            width: 24.w,
          ),
        ],
      ],
    );
  }
}

// 언어 옵션을 위한 데이터 클래스
class LocaleOption {
  const LocaleOption({
    required this.locale,
    required this.name,
    required this.flag,
    this.fontFamily = 'Pretendard',
  });

  final Locale locale;
  final String name;
  final String flag;
  final String fontFamily;
}
