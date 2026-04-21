import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

final localDbServiceProvider = Provider<LocalDbService>((_) => LocalDbService());

class LocalDbService {
  static String get _dbPath {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return p.join(exeDir, 'local_db.json');
  }

  static String get _configPath {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    return p.join(exeDir, 'config.json');
  }

  Future<int> getInitialCount({required bool isSingle}) async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) return 0;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final key = isSingle ? 'singleCardCount' : 'doubleCardCount';
      return (json[key] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getRemainingCount({required bool isSingle}) async {
    try {
      final db = await _readDb();
      final key = isSingle ? 'remainingSingleCount' : 'remainingDoubleCount';
      if (db.containsKey(key)) return (db[key] as num).toInt();
      return await getInitialCount(isSingle: isSingle);
    } catch (_) {
      return await getInitialCount(isSingle: isSingle);
    }
  }

  Future<void> saveCount({required bool isSingle, required int count}) async {
    final db = await _readDb();
    final key = isSingle ? 'remainingSingleCount' : 'remainingDoubleCount';
    await _writeDb({...db, key: count});
  }

  Future<void> writePrintLog({required bool isSingle}) async {
    final db = await _readDb();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // printLogs
    final logs = List<String>.from((db['printLogs'] as List?) ?? []);
    logs.add('$timestamp [${isSingle ? '단면' : '양면'}]');

    // total
    final total = Map<String, dynamic>.from((db['total'] as Map?) ?? {});
    if (isSingle) {
      total['singlePrinted'] = ((total['singlePrinted'] as num?)?.toInt() ?? 0) + 1;
    } else {
      total['doublePrinted'] = ((total['doublePrinted'] as num?)?.toInt() ?? 0) + 1;
    }

    Map<String, dynamic> update = {
      ...db,
      'total': total,
      'lastPrintedAt': timestamp,
      'printLogs': logs,
    };

    if (isSingle) {
      final current = (db['remainingSingleCount'] as num?)?.toInt() ?? await getInitialCount(isSingle: true);
      update['remainingSingleCount'] = current - 1 < 0 ? 0 : current - 1;
    }

    await _writeDb(update);
  }

  Future<void> writeErrorLog(String message) async {
    final db = await _readDb();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final errors = List<String>.from((db['errorLogs'] as List?) ?? []);
    errors.add('$timestamp $message');
    await _writeDb({...db, 'errorLogs': errors});
  }

  Future<Map<String, dynamic>> _readDb() async {
    final file = File(_dbPath);
    if (!await file.exists()) return {};
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeDb(Map<String, dynamic> data) async {
    const encoder = JsonEncoder.withIndent('  ');
    await File(_dbPath).writeAsString(encoder.convert(data), flush: true);
  }
}
