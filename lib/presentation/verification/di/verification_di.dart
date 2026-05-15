import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:flutter_snaptag_kiosk/domain/domain.dart';
import 'package:flutter_snaptag_kiosk/flavors.dart';
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
