import 'package:freezed_annotation/freezed_annotation.dart';

part 'setup_main_state.freezed.dart';

@freezed
sealed class SetupMainState with _$SetupMainState {
  const factory SetupMainState.initial() = SetupMainStateInitial;
  const factory SetupMainState.loading() = SetupMainStateLoading;
  const factory SetupMainState.awaitingEventConfirmation() = SetupMainStateAwaitingEventConfirmation;
  const factory SetupMainState.eventStartSuccess() = SetupMainStateEventStartSuccess;
  const factory SetupMainState.exitAppSuccess() = SetupMainStateExitAppSuccess;
  const factory SetupMainState.failure(SetupMainFailure failure) = SetupMainStateFailure;
}

@freezed
sealed class SetupMainFailure with _$SetupMainFailure {
  const factory SetupMainFailure.printerNotConnected() = SetupMainFailurePrinterNotConnected;
  const factory SetupMainFailure.printerNotReady() = SetupMainFailurePrinterNotReady;
  const factory SetupMainFailure.paymentDeviceNotReady() = SetupMainFailurePaymentDeviceNotReady;
  const factory SetupMainFailure.kioskInfoInvalid() = SetupMainFailureKioskInfoInvalid;
  const factory SetupMainFailure.printTypeNotSelected() = SetupMainFailurePrintTypeNotSelected;
  const factory SetupMainFailure.eventStartFailed(Object error) = SetupMainFailureEventStartFailed;
}
