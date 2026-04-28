import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/mappers/verification_mapper.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/verification_failure.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/verification_repository.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verification_repository_impl.g.dart';

@riverpod
VerificationRepository verificationRepository(Ref ref) {
  final dio = ref.watch(dioProvider(F.kioskBaseUrl));
  return VerificationRepositoryImpl(KioskApiClient(dio));
}

class VerificationRepositoryImpl implements VerificationRepository {
  final KioskApiClient _apiClient;

  VerificationRepositoryImpl(this._apiClient);

  @override
  Future<Result<BackPhotoCard, VerificationFailure>> verifyCode({
    required int kioskEventId,
    required String authCode,
  }) async {
    try {
      final dto = await _apiClient.getBackPhotoCard(
        kioskEventId: kioskEventId,
        photoAuthNumber: authCode,
      );
      return Success(dto.toModel());
    } on DioException catch (e) {
      return _mapDioException(e);
    } catch (e) {
      return Failure(VerificationFailureUnknown(e.toString()));
    }
  }

  Result<BackPhotoCard, VerificationFailure> _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data as Map<String, dynamic>?;

    return switch (statusCode) {
      410 => const Failure(VerificationFailureExpired()),
      409 => Failure(VerificationFailureRefundRequired(
          order: _parseOrder(data?['res']?['order']),
        )),
      _ => const Failure(VerificationFailureNetwork()),
    };
  }

  OrderErrorEntity? _parseOrder(dynamic orderData) {
    if (orderData is Map<String, dynamic>) {
      try {
        return OrderErrorEntity.fromJson(orderData);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
