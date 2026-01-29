import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

Future<Uint8List> encryptMacAddressWithChaCha20(String mac) async {
  final key = utf8.encode('this-is-32-byte-secret-key-12345'); // 32바이트
  final nonce = utf8.encode('uuid-nonce-1'); // 12바이트

  final algorithm = Chacha20(macAlgorithm: MacAlgorithm.empty);
  final secretKey = SecretKey(key);

  final message = mac.split('-').map((hex) => int.parse(hex, radix: 16)).toList();
  final encrypted = await algorithm.encrypt(
    message,
    secretKey: secretKey,
    nonce: nonce,
  );
  print("encrypted.ciphcerText: ${encrypted.cipherText}");

  return Uint8List.fromList(encrypted.cipherText);
}
