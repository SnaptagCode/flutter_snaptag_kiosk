import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/setup_remote_data_source_impl.dart';
import 'package:flutter_snaptag_kiosk/setup/data/repository_impl/setup_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/setup/domain/repository/i_setup_repository.dart';
import 'package:flutter_snaptag_kiosk/setup/domain/usecase/end_kiosk_application_use_case.dart';
import 'package:flutter_snaptag_kiosk/setup/domain/usecase/start_kiosk_event_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_di.g.dart';

@riverpod
ISetupRepository setupRepository(Ref ref) {
  final dio = ref.watch(dioProvider(F.kioskBaseUrl));
  final dataSource = SetupRemoteDataSourceImpl(KioskApiClient(dio));
  return SetupRepositoryImpl(dataSource);
}

@riverpod
StartKioskEventUseCase startKioskEventUseCase(Ref ref) {
  return StartKioskEventUseCase(ref);
}

@riverpod
EndKioskApplicationUseCase endKioskApplicationUseCase(Ref ref) {
  return EndKioskApplicationUseCase(ref);
}
