import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/verification/data/data_source/i_verification_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/verification/data/data_source/verification_remote_data_source_impl.dart';
import 'package:flutter_snaptag_kiosk/verification/data/repository_impl/verification_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/verification/domain/repository/i_verification_repository.dart';
import 'package:flutter_snaptag_kiosk/verification/domain/usecase/verify_photo_code_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verification_di.g.dart';

@riverpod
IVerificationRemoteDataSource verificationRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider(F.kioskBaseUrl));
  return VerificationRemoteDataSourceImpl(KioskApiClient(dio));
}

@riverpod
IVerificationRepository verificationRepository(Ref ref) {
  return VerificationRepositoryImpl(ref.watch(verificationRemoteDataSourceProvider));
}

@riverpod
VerifyPhotoCodeUseCase verifyPhotoCodeUseCase(Ref ref) {
  return VerifyPhotoCodeUseCase(ref.watch(verificationRepositoryProvider));
}
