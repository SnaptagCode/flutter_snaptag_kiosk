import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_action.freezed.dart';

@freezed
sealed class VerificationAction with _$VerificationAction {
  const factory VerificationAction.submit(String code) = VerificationActionSubmit;
  const factory VerificationAction.cancel() = VerificationActionCancel;
}
