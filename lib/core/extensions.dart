import 'package:flutter/widgets.dart';

extension TextTranslateExtension on Text {
  Widget validate() {
    if (data?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    return this;
  }
}
