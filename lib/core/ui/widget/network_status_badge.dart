import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/providers/network_status_provider.dart';

/// 네트워크 연결 상태를 표시하는 배지 위젯
class NetworkStatusBadge extends ConsumerWidget {
  const NetworkStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkStatusNotifierProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _getStatusColor(networkState.status),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(networkState.status),
          SizedBox(width: 6.w),
          Text(
            _getStatusText(networkState.status, networkState.type),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(NetworkStatus status) {
    IconData iconData;
    double size = 14.sp;

    switch (status) {
      case NetworkStatus.connected:
        iconData = Icons.wifi;
        break;
      case NetworkStatus.connecting:
        iconData = Icons.sync;
        size = 12.sp;
        break;
      case NetworkStatus.unstable:
        iconData = Icons.wifi_off;
        break;
      case NetworkStatus.disconnected:
        iconData = Icons.signal_wifi_off;
        break;
    }

    return status == NetworkStatus.connecting
        ? SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Icon(
            iconData,
            size: size,
            color: Colors.white,
          );
  }

  Color _getStatusColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.connecting:
        return Colors.orange;
      case NetworkStatus.unstable:
        return Colors.orange.shade700;
      case NetworkStatus.disconnected:
        return Colors.red;
    }
  }

  String _getStatusText(NetworkStatus status, NetworkType type) {
    switch (status) {
      case NetworkStatus.connected:
        return _getTypeText(type);
      case NetworkStatus.connecting:
        return '연결 중...';
      case NetworkStatus.unstable:
        return '불안정';
      case NetworkStatus.disconnected:
        return '연결 끊김';
    }
  }

  String _getTypeText(NetworkType type) {
    switch (type) {
      case NetworkType.wifi:
        return 'WiFi';
      case NetworkType.mobile:
        return '모바일';
      case NetworkType.ethernet:
        return '유선';
      case NetworkType.none:
        return '없음';
    }
  }
}

/// 네트워크 상태를 표시하는 간단한 인디케이터 (작은 원형 아이콘)
class NetworkStatusIndicator extends ConsumerWidget {
  const NetworkStatusIndicator({super.key, this.size = 12});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkStatusNotifierProvider);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getStatusColor(networkState.status),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.connecting:
        return Colors.orange;
      case NetworkStatus.unstable:
        return Colors.orange.shade700;
      case NetworkStatus.disconnected:
        return Colors.red;
    }
  }
}
