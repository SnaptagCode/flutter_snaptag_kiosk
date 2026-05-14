import 'package:freezed_annotation/freezed_annotation.dart';

part 'print_action.freezed.dart';

@freezed
sealed class PrintAction with _$PrintAction {
  const factory PrintAction.retry() = PrintActionRetry;
}
