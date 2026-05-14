import 'dart:convert';
import 'dart:io';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/payment/data/datasource/i_payment_datasource.dart';
import 'package:http/http.dart' as http;

class PaymentApiClient implements IPaymentDatasource {
  PaymentApiClient();

  static const int _defaultWebPort = 27098;
  static const String _configPath = r'C:\KSCAT\config.ini';

  static String? _cachedBaseUrl;

  Future<String> _resolveBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    try {
      final ini = await File(_configPath).readAsString();
      final daemon = _parseIniSection(ini, 'daemon');

      final webPort = int.tryParse((daemon['webport'] ?? '').trim()) ?? _defaultWebPort;
      final baseUrl = 'http://127.0.0.1:$webPort';

      _cachedBaseUrl = baseUrl;
      logger.i('KSCAT baseUrl resolved from INI: $baseUrl ($_configPath)');
      return baseUrl;
    } catch (e) {
      final baseUrl = 'http://127.0.0.1:$_defaultWebPort';
      _cachedBaseUrl = baseUrl;
      logger.w('Failed to read/parse KSCAT INI ($_configPath). Falling back to $baseUrl. Error: $e');
      return baseUrl;
    }
  }

  Map<String, String> _parseIniSection(String ini, String sectionName) {
    final target = sectionName.trim().toLowerCase();
    final map = <String, String>{};

    String? currentSection;
    for (final rawLine in const LineSplitter().convert(ini)) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line.startsWith(';') || line.startsWith('#')) continue;

      if (line.startsWith('[') && line.endsWith(']')) {
        currentSection = line.substring(1, line.length - 1).trim().toLowerCase();
        continue;
      }

      if (currentSection != target) continue;

      final idx = line.indexOf('=');
      if (idx <= 0) continue;

      final key = line.substring(0, idx).trim().toLowerCase();
      final value = line.substring(idx + 1).trim();
      map[key] = value;
    }

    return map;
  }

  @override
  Future<PaymentResponse> requestPayment(String callback, String request) async {
    final baseUrl = await _resolveBaseUrl();
    final url = '$baseUrl?callback=$callback&REQ=$request';
    logger.i('\n=== Raw Payment Request URL ===\n$url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=euc-kr'},
    );

    final body = response.body;
    final broken = body.substring(
      callback.length + 1,
      body.length - 1,
    );

    final decode = cp949.decodeString(broken);
    final trim = trimValues(json.decode(decode));
    final paymentResponse = trim..addAll({'KSNET': '$callback($trim)'});
    logger.i(paymentResponse.toString());
    return PaymentResponse.fromJson(paymentResponse);
  }

  @override
  Future<KscatDeviceResponse> requestDevice(String callback, String request) async {
    final baseUrl = await _resolveBaseUrl();
    final url = '$baseUrl?callback=$callback&REQ=$request';
    logger.i('\n=== Raw KscatDevice Request URL ===\n$url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=euc-kr'},
    );

    final body = response.body;
    final broken = body.substring(
      callback.length + 1,
      body.length - 1,
    );

    final decode = cp949.decodeString(broken);
    final trim = trimValues(json.decode(decode));
    final kscatDeviceResponse = trim..addAll({'KSNET': '$callback($trim)'});
    logger.i(kscatDeviceResponse.toString());
    return KscatDeviceResponse.fromJson(kscatDeviceResponse);
  }

  Map<String, dynamic> trimValues(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is String) {
        return MapEntry(key, value.trim());
      }
      return MapEntry(key, value);
    });
  }
}
