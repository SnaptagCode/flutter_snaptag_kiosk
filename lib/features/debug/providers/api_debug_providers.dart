import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/models/enums/enums.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_debug_providers.g.dart';

// API 응답 상태를 관리하는 공통 클래스
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const ApiResponse({this.data, this.error, this.isLoading = false});

  ApiResponse<T> copyWith({T? data, String? error, bool? isLoading}) {
    return ApiResponse(
      data: data ?? this.data,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class MachineInfo extends _$MachineInfo {
  @override
  ApiResponse<dynamic> build() => const ApiResponse();

  Future<void> fetch(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(kioskRepositoryProvider);
      final response = await repository.getKioskMachineInfo(id);
      state = ApiResponse(data: response);
    } catch (e) {
      state = ApiResponse(error: e.toString());
    }
  }
}

@riverpod
class UpdatePrintStatus extends _$UpdatePrintStatus {
  @override
  ApiResponse<dynamic> build() => const ApiResponse();

  Future<void> update({
    required int kioskMachineId,
    required int kioskEventId,
    required int frontPhotoCardId,
    required String photoAuthNumber,
    required PrintStatus status,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(kioskRepositoryProvider);
      final response = await repository.updatePrintStatus(
        kioskMachineId: kioskMachineId,
        kioskEventId: kioskEventId,
        frontPhotoCardId: frontPhotoCardId,
        photoAuthNumber: photoAuthNumber,
        status: status,
      );
      state = ApiResponse(data: response);
    } catch (e) {
      state = ApiResponse(error: e.toString());
    }
  }
}

@riverpod
class FrontPhotoList extends _$FrontPhotoList {
  @override
  ApiResponse<dynamic> build() => const ApiResponse();

  Future<void> fetch(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(kioskRepositoryProvider);
      final response = await repository.getFrontPhotoList(id);
      state = ApiResponse(data: response);
    } catch (e) {
      state = ApiResponse(error: e.toString());
    }
  }
}

@riverpod
class BackPhotoCard extends _$BackPhotoCard {
  @override
  ApiResponse<dynamic> build() => const ApiResponse();

  Future<void> fetch(int id, String authNumber) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(kioskRepositoryProvider);
      final response = await repository.getBackPhotoCard(id, authNumber);
      state = ApiResponse(data: response);
    } catch (e) {
      state = ApiResponse(error: e.toString());
    }
  }
}

@riverpod
class CreateOrder extends _$CreateOrder {
  @override
  ApiResponse<dynamic> build() => const ApiResponse();

  Future<void> create(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(kioskRepositoryProvider);
      final response = await repository.createOrder(data);
      state = ApiResponse(data: response);
    } catch (e) {
      state = ApiResponse(error: e.toString());
    }
  }
}

@riverpod
class UpdateOrder extends _$UpdateOrder {
  @override
  ApiResponse<dynamic> build() => const ApiResponse();

  Future<void> update(int id, OrderStatus status) async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(kioskRepositoryProvider);
      final response = await repository.updateOrder(id, status);
      state = ApiResponse(data: response);
    } catch (e) {
      state = ApiResponse(error: e.toString());
    }
  }
}
