import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_code_provider.g.dart';

@riverpod
class AuthCode extends _$AuthCode {
  static const int maxLength = 4;

  @override
  ({String input, String formattedInput}) build() {
    return (input: '', formattedInput: '');
  }

  void addNumber(String number) {
    if (state.input.length < maxLength) {
      final newInput = state.input + number;
      state = (
        input: newInput,
        formattedInput: _formatInput(newInput),
      );
    }
  }

  void reset() {
    state = (input: '', formattedInput: '');
  }

  void removeLast() {
    if (state.input.isNotEmpty) {
      final newInput = state.input.substring(0, state.input.length - 1);
      state = (
        input: newInput,
        formattedInput: _formatInput(newInput),
      );
    }
  }

  void clear() {
    state = (input: '', formattedInput: '');
  }

  Future<void> submit() async {
    String authCode = state.input;
    logger.d('Auth code submitted: $authCode');
  }

  String _formatInput(String input) {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buffer.write(input[i]);
      if ((i + 1) % 4 == 0 && i + 1 != input.length) {
        buffer.write('-');
      }
    }
    return buffer.toString();
  }
}
