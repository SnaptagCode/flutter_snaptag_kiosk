import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

/// 프린트 로직을 담당하는 UseCase
///
/// - 내부에서 [Reader read]를 사용하여
///   [kioskRepositoryProvider], [labcurityServiceProvider], [printerServiceProvider] 등을 참조함.
class PrintUseCase {
  final Ref ref;

  PrintUseCase({required this.ref});

  /// 실제 프린팅 전체 과정을 수행
  ///
  /// [frontPhotoInfo], [backPhotoForPrintInfo]는 호출부(Service)에서 확보해 전달.
  Future<void> doPrint({
    required NominatedPhoto frontPhotoInfo,
    required BackPhotoForPrint backPhotoForPrintInfo,
  }) async {
    final kioskRepository = ref.read(kioskRepositoryProvider);
    final labcurityService = ref.read(labcurityServiceProvider);

    // 1) 백이미지 labcurity 처리
    final embeddedBackImage = await _prepareBackImage(
      backPhotoForPrintInfo,
      labcurityService,
    );

    // 2) printStatus 생성
    final kioskInfo = ref.read(kioskInfoServiceProvider);
    if (kioskInfo == null) {
      throw Exception('No kiosk info');
    }
    final createPrintRequest = CreatePrintRequest(
      kioskMachineId: kioskInfo.kioskMachineId,
      kioskEventId: kioskInfo.kioskEventId,
      frontPhotoCardId: frontPhotoInfo.id,
      backPhotoCardId: backPhotoForPrintInfo.backPhotoCardId,
      file: embeddedBackImage,
    );
    final createPrintResponse = await kioskRepository.createPrintStatus(
      request: createPrintRequest,
    );
    final printedPhotoCardId = createPrintResponse.printedPhotoCardId;

    // 3) 프린트 시작 상태로 업데이트
    await _updatePrintStatus(
      printedPhotoCardId,
      PrintedStatus.started,
      kioskInfo,
    );

    try {
      // 4) 실제 물리 프린트
      final printerNotifier = ref.read(printerServiceProvider.notifier);
      await printerNotifier.printImage(
        frontFile: frontPhotoInfo.safeEmbedImage,
        embeddedFile: embeddedBackImage,
      );

      // 5) 프린트 완료
      await _updatePrintStatus(
        printedPhotoCardId,
        PrintedStatus.completed,
        kioskInfo,
      );
    } catch (e) {
      // 프린트 실패
      await _updatePrintStatus(
        printedPhotoCardId,
        PrintedStatus.failed,
        kioskInfo,
      );
      rethrow;
    } finally {
      if (await embeddedBackImage.exists()) {
        await embeddedBackImage.delete();
      }
    }
  }

  Future<File> _prepareBackImage(
    BackPhotoForPrint info,
    LabcurityService labcurityService,
  ) async {
    final response = await ImageHelper().getImageBytes(info.formattedImageUrl);
    return labcurityService.embedImage(
      response.data,
      LabcurityImageConfig(
        size: 3,
        strength: 16,
        alphaCode: info.versionCode,
        bravoCode: info.countryCode,
        charlieCode: info.industryCode,
        deltaCode: info.customerCode,
        echoCode: info.projectCode,
        foxtrotCode: info.productCode,
      ),
    );
  }

  Future<void> _updatePrintStatus(
    int printedPhotoCardId,
    PrintedStatus status,
    KioskMachineInfo kioskInfo,
  ) async {
    final request = UpdatePrintRequest(
      kioskMachineId: kioskInfo.kioskMachineId,
      kioskEventId: kioskInfo.kioskEventId,
      status: status,
    );
    await ref.read(kioskRepositoryProvider).updatePrintStatus(
          printedPhotoCardId: printedPhotoCardId,
          request: request,
        );
  }
}
