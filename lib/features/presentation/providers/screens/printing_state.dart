import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'printing_state.g.dart';

@Riverpod(keepAlive: true)
class PrintingState extends _$PrintingState {
  @override
  bool build() => false;

  void updatePrinting(bool value) {
    state = value;
  }
}
