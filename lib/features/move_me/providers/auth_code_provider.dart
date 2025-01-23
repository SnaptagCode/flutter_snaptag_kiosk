import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_code_provider.g.dart';

@riverpod
class AuthCode extends _$AuthCode {
  static const int maxLength = 4;

  @override
  String build() {
    return '';
  }

  void addNumber(String number) {
    if (state.length < maxLength) {
      state = state + number;
    }
  }

  void removeLast() {
    if (state.isNotEmpty) {
      state = state.substring(0, state.length - 1);
    }
  }

  void clear() {
    state = '';
  }

  bool isValid() {
    return state.length == maxLength;
  }
}
