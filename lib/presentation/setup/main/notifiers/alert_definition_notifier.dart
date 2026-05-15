import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'alert_definition_notifier.g.dart';

@Riverpod(keepAlive: true)
class AlertDefinition extends _$AlertDefinition {
  @override
  List<AlertDefinitionResponse> build() => [];

  Future<void> load() async {
    final kioskRepo = ref.read(kioskRepositoryProvider);
    final list = await kioskRepo.getAlertDefinition();
    state = list;
  }

  AlertDefinitionResponse? findByKey(String key) {
    return state.firstWhereOrNull((e) => e.key == key);
  }
}
