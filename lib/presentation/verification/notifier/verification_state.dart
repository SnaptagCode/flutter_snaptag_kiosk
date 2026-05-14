import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/verification_failure.dart';

part 'verification_state.freezed.dart';

@freezed
class VerificationState with _$VerificationState {
  const factory VerificationState.initial() = VerificationStateInitial;
  const factory VerificationState.loading() = VerificationStateLoading;
  const factory VerificationState.success(BackPhotoCard card) = VerificationStateSuccess;
  const factory VerificationState.failure(VerificationFailure failure) = VerificationStateFailure;
}
