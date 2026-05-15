import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/core/result/result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/refund_order_info.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/verification_failure.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/i_verification_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/data/models/verification_mapper.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_verification_repository.dart';

class VerificationRepositoryImpl implements IVerificationRepository {
  final IVerificationRemoteDataSource _dataSource;

  VerificationRepositoryImpl(this._dataSource);

  @override
  Future<Result<BackPhotoCard, VerificationFailure>> verifyCode({
    required int kioskEventId,
    required String authCode,
  }) async {
    try {
      final dto = await _dataSource.getBackPhotoCard(
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
      404 => const Failure(VerificationFailureInvalidCode()),
      409 => Failure(VerificationFailureRefundRequired(
          order: _parseOrder(data?['res']?['order']),
        )),
      410 => const Failure(VerificationFailureExpired()),
      _ => const Failure(VerificationFailureNetwork()),
    };
  }

  RefundOrderInfo? _parseOrder(dynamic orderData) {
    if (orderData is Map<String, dynamic>) {
      try {
        return RefundOrderInfo(
          orderId: (orderData['orderId'] as num?)?.toInt(),
          authSeqNumber: orderData['authSeqNumber'] as String?,
          completedAt: orderData['completedAt'] == null
              ? null
              : DateTime.parse(orderData['completedAt'] as String),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
