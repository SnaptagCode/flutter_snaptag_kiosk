import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_service.g.dart';

@riverpod
class PrintService extends _$PrintService {
  @override
  FutureOr<void> build() => null;

  // UseCase를 read()하여 주입
  late final PrintUseCase _printUseCase = PrintUseCase(ref: ref);

  Future<void> print() async {
    try {
      // 기존 사전 검증 로직
      final backPhotoForPrint = ref.read(backPhotoForPrintInfoProvider);
      final backPhotoCardResponse = ref.watch(verifyPhotoCardProvider).value;
      final approvalInfo = ref.read(paymentResponseStateProvider);

      if (backPhotoForPrint == null) {
        throw Exception('No back photo for print info');
      }
      if (backPhotoCardResponse == null) {
        throw Exception('No back photo card response');
      }
      if (approvalInfo == null) {
        throw Exception('No payment approval info');
      }

      // 프론트 이미지 선정
      final frontPhoto = await ref.read(frontPhotoListProvider.notifier).getRandomPhoto();

      // UseCase 호출
      await _printUseCase.doPrint(
        frontPhotoInfo: frontPhoto,
        backPhotoForPrintInfo: backPhotoForPrint,
      );

      // 이후 상태 갱신
      // ...
    } catch (e, stack) {
      logger.e('PrintService.print failure', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
