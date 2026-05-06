import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_status_provider.g.dart';

/// 네트워크 연결 상태
enum NetworkStatus {
  /// 연결됨 - 인터넷에 정상적으로 연결됨
  connected,

  /// 연결 중 - 연결 시도 중
  connecting,

  /// 불안정 - 연결은 되지만 불안정함 (간헐적 연결 끊김)
  unstable,

  /// 연결 끊김 - 네트워크 연결이 없음
  disconnected,
}

/// 네트워크 연결 타입
enum NetworkType {
  wifi,
  mobile,
  ethernet,
  none,
}

/// 네트워크 상태 정보
class NetworkState {
  final NetworkStatus status;
  final NetworkType type;
  final bool hasInternet;
  final DateTime lastChecked;

  const NetworkState({
    required this.status,
    required this.type,
    required this.hasInternet,
    required this.lastChecked,
  });

  NetworkState copyWith({
    NetworkStatus? status,
    NetworkType? type,
    bool? hasInternet,
    DateTime? lastChecked,
  }) {
    return NetworkState(
      status: status ?? this.status,
      type: type ?? this.type,
      hasInternet: hasInternet ?? this.hasInternet,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

@Riverpod(keepAlive: true)
class NetworkStatusNotifier extends _$NetworkStatusNotifier {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _checkTimer;
  int _consecutiveFailures = 0;

  static const int _maxFailures = 3;
  static const _pingTimeout = Duration(seconds: 5);
  static const _pingInterval = Duration(seconds: 5);
  static const _pingUrls = [
    'https://www.google.com/generate_204',
    'http://www.gstatic.com/generate_204',
    'https://www.naver.com',
    'http://www.msftconnecttest.com/connecttest.txt',
  ];

  @override
  NetworkState build() {
    _startMonitoring();
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
      _checkTimer?.cancel();
    });
    return NetworkState(
      status: NetworkStatus.connecting,
      type: NetworkType.none,
      hasInternet: false,
      lastChecked: DateTime.now(),
    );
  }

  /// 네트워크 모니터링 시작
  void _startMonitoring() {
    _checkNetworkStatus();

    // OS 레벨 연결 타입 변화 감지
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _handleConnectivityChange(results);
      },
    );

    // 5초마다 ping 체크
    _checkTimer = Timer.periodic(_pingInterval, (_) {
      _checkNetworkStatus();
    });
  }

  /// 네트워크 상태 확인
  Future<void> _checkNetworkStatus() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      _handleConnectivityChange(connectivityResults);

      final hasInternet = await _sequentialPingCheck();
      _updateInternetStatus(hasInternet);
    } catch (e) {
      state = state.copyWith(
        status: NetworkStatus.disconnected,
        lastChecked: DateTime.now(),
      );
    }
  }

  /// 순차 ping 체크: 하나 성공 시 즉시 true 반환, 전부 실패 시 false
  Future<bool> _sequentialPingCheck() async {
    for (final url in _pingUrls) {
      try {
        final response = await http.head(Uri.parse(url)).timeout(_pingTimeout);
        if (response.statusCode >= 100 && response.statusCode < 600) {
          logger.i('_sequentialPingCheck: success [$url]');
          return true;
        }
      } catch (_) {
        logger.i('_sequentialPingCheck: failed [$url]');
      }
    }
    return false;
  }

  /// 연결 타입 변경 처리
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    NetworkType type = NetworkType.none;

    if (results.contains(ConnectivityResult.wifi)) {
      type = NetworkType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      type = NetworkType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      type = NetworkType.ethernet;
    }

    state = state.copyWith(
      type: type,
      lastChecked: DateTime.now(),
    );

    // 연결 타입이 없으면 연결 끊김 상태
    if (type == NetworkType.none) {
      state = state.copyWith(
        status: NetworkStatus.disconnected,
        hasInternet: false,
      );
    }
  }

  /// 인터넷 연결 상태 업데이트
  void _updateInternetStatus(bool hasInternet) {
    NetworkStatus newStatus;

    logger.i('_updateInternetStatus: $hasInternet');

    if (state.type == NetworkType.none) {
      newStatus = NetworkStatus.disconnected;
      _consecutiveFailures = 0;
    } else if (hasInternet) {
      _consecutiveFailures = 0;
      newStatus = NetworkStatus.connected;
    } else {
      _consecutiveFailures++;
      if (_consecutiveFailures >= _maxFailures) {
        newStatus = NetworkStatus.disconnected;
      } else if (_consecutiveFailures >= 2) {
        newStatus = NetworkStatus.unstable;
      } else {
        newStatus = NetworkStatus.connecting;
      }
    }

    logger.i('newStatus: $newStatus');

    state = state.copyWith(
      status: newStatus,
      hasInternet: hasInternet,
      lastChecked: DateTime.now(),
    );
  }

  bool isNetworkError(dynamic error) {
    return error is DioException &&
        (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.unknown);
  }

  /// 수동으로 네트워크 상태 새로고침
  Future<void> refresh() async {
    await _checkNetworkStatus();
  }
}
