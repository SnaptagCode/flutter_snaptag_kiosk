import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        flag: 'assets/images/kr.png',
      ),
      LocaleOption(
        locale: const Locale('en', 'US'),
        name: 'English',
        flag: 'assets/images/am.png',
      ),
      LocaleOption(
        locale: const Locale('ja', 'JP'),
        name: '日本語',
        flag: 'assets/images/jp.png',
      ),
    ];

    // 현재 선택된 언어 옵션 찾기
    final LocaleOption selectedOption = localeOptions.firstWhere(
      (option) => option.locale.languageCode == currentLocale.languageCode,
      orElse: () => localeOptions.first,
    );

    return Padding(
      padding: EdgeInsets.all(8.r),
      child: SizedBox(
          height: 44.h,
          // width: 162.w,
          child: PopupMenuButton<Locale>(
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
                    child: MenuWidget(
                      option: option,
                      isSelected: false,
                    ))
            ],
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.r),
                color: Colors.white,
              ),
              child: MenuWidget(
                option: selectedOption,
                isSelected: true,
              ),
            ),
          )),
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
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              child: Image.asset(
                option.flag,
                width: 32.w,
                height: 24.h,
              ),
            ),
            Text(
              option.name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        if (isSelected) ...[
          SizedBox(width: 20.w),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.black,
          ),
        ],
        SizedBox(width: 20.w),
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
  });

  final Locale locale;
  final String name;

  final String flag;
}
