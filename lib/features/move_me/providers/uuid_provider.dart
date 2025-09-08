import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_snaptag_kiosk/core/utils/uuid/mac_util.dart";
import "package:flutter_snaptag_kiosk/core/utils/uuid/crypto_util.dart";
import "dart:convert";

final macAddressProvider = FutureProvider<String>((ref) async {
  return await getWindowsMacAddress();
});

final deviceUuidProvider = FutureProvider<String>((ref) async {
  final mac = await ref.watch(macAddressProvider.future);
  print("deviceUuidProvider: ${mac.replaceAll('-', ':')}");
  //final key = utf8.encode('this-is-32-byte-secret-key-123456');
  //final nonce = utf8.encode('uuid-nonce-01');
  final encrypted = await encryptMacAddressWithChaCha20(mac);
  print("deviceUuidProvider: $encrypted");
  return encrypted.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
});