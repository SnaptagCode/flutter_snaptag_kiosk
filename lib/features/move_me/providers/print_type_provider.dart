import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_type_provider.g.dart';

@riverpod
class PrintType extends _$PrintType {
  @override
  PrintMode build() => PrintMode.duplex;

  void switchType() {
    switch (state) {
      case PrintMode.simplex:
        state = PrintMode.duplex;
      case PrintMode.duplex:
        state = PrintMode.simplex;
    }
  }
}

enum PrintMode {
  duplex, // 양면 인쇄
  simplex // 단면 인쇄
}
