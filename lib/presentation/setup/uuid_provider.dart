import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_snaptag_kiosk/core/common/uuid/mac_util.dart";
import "package:flutter_snaptag_kiosk/core/common/uuid/crypto_util.dart";

final macAddressProvider = FutureProvider<({String name, String mac})>((ref) async {
  return await getWindowsMacAddress();
});

final deviceUuidProvider = FutureProvider<String>((ref) async {
  final info = await ref.watch(macAddressProvider.future);
  final encrypted = await encryptMacAddressWithChaCha20(info.mac);
  return encrypted.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
});
