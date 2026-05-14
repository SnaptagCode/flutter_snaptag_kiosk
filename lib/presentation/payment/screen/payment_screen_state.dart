import 'package:flutter_snaptag_kiosk/presentation/home/notifier/home_back_photo_type_notifier.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_screen_state.freezed.dart';

@freezed
class PaymentScreenState with _$PaymentScreenState {
  const factory PaymentScreenState({
    required bool isLoading,
    KioskMachineInfo? kiosk,
    BackPhotoSelection? selection,
    String? backPhotoUrl,
    @Default(false) bool isBackPhotoLoading,
    Object? backPhotoError,
  }) = _PaymentScreenState;
}
