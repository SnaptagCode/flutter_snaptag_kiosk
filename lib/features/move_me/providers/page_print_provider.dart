import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_print_provider.g.dart';

@Riverpod(keepAlive: true)
class PagePrint extends _$PagePrint {
  @override
  PagePrintType build() => PagePrintType.none;

  void switchType() {
    state = state == PagePrintType.double ? PagePrintType.single : PagePrintType.double;
  }
  void set(PagePrintType type) => state = type;
}

enum PagePrintType {
  single, // 양면 인쇄
  double, // 단면 인쇄
  none // 인쇄모드 미선택
}
