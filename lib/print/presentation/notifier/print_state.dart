import 'package:freezed_annotation/freezed_annotation.dart';

part 'print_state.freezed.dart';

@freezed
class PrintState with _$PrintState {
  const factory PrintState.initial() = PrintStateInitial;
  const factory PrintState.loading() = PrintStateLoading;
  const factory PrintState.success() = PrintStateSuccess;
  const factory PrintState.failure(Object error, StackTrace stackTrace) = PrintStateFailure;
}
