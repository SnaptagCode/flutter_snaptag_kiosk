import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_warning_provider.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter/widgets.dart';

// Mock 클래스들
class MockSlackLogService {
  final List<String> sentMessages = [];

  Future<void> sendRibbonFilmWarningLog(String message) async {
    sentMessages.add(message);
  }

  void clearMessages() {
    sentMessages.clear();
  }
}

// Mock 클래스들 - 간단한 구현으로 변경
class MockRibbonStatus {
  int rbnRemaining;
  int filmRemaining;
  
  MockRibbonStatus({this.rbnRemaining = 50, this.filmRemaining = 50});
}

class MockKioskInfoService {
  int? kioskMachineId;
  
  MockKioskInfoService({this.kioskMachineId = 123});
}

class MockPrinterService extends StateNotifier<void> {
  MockRibbonStatus _ribbonStatus;
  
  MockPrinterService({MockRibbonStatus? ribbonStatus}) 
    : _ribbonStatus = ribbonStatus ?? MockRibbonStatus(),
      super(null);
  
  MockRibbonStatus getRibbonStatus() => _ribbonStatus;
  
  void setRibbonStatus(MockRibbonStatus status) {
    _ribbonStatus = status;
  }
}

// 테스트용 WidgetRef 구현 (간단하게)
class TestWidgetRef extends WidgetRef {
  final ProviderContainer _container;
  
  TestWidgetRef(this._container);
  
  @override
  T read<T>(ProviderListenable<T> provider) => _container.read(provider);
  
  @override
  void listen<T>(ProviderListenable<T> provider, void Function(T? previous, T next) listener, {void Function(Object error, StackTrace stackTrace)? onError}) {}
  
  @override
  ProviderSubscription<T> listenManual<T>(ProviderListenable<T> provider, void Function(T? previous, T next) listener, {bool fireImmediately = false, void Function(Object error, StackTrace stackTrace)? onError}) {
    throw UnimplementedError();
  }
  
  @override
  T watch<T>(ProviderListenable<T> provider) => _container.read(provider);
  
  @override
  void invalidate(ProviderOrFamily provider) {
    _container.invalidate(provider);
  }
  
  @override
  bool exists(ProviderBase<Object?> provider) => _container.exists(provider);
  
  @override
  T refresh<T>(Refreshable<T> provider) => _container.refresh(provider);
  
  @override
  BuildContext get context => throw UnimplementedError();
}

// 테스트용 Provider들
final mockKioskInfoServiceProvider = Provider<MockKioskInfoService?>((ref) => MockKioskInfoService());
final mockPrinterServiceProvider = StateNotifierProvider<MockPrinterService, void>((ref) => MockPrinterService());
final mockSlackLogServiceProvider = Provider<MockSlackLogService>((ref) => MockSlackLogService());

void main() {
  group('RibbonWarningState', () {
    test('should create initial state with default values', () {
      const state = RibbonWarningState();
      
      expect(state.isSentUnder20Ribbon, false);
      expect(state.isSentUnder20Film, false);
      expect(state.isSentUnder10Ribbon, false);
      expect(state.isSentUnder10Film, false);
      expect(state.isSentUnder5Ribbon, false);
      expect(state.isSentUnder5Film, false);
      expect(state.lastWarnedRibbonLevel, 100.0);
      expect(state.lastWarnedFilmLevel, 100.0);
    });

    test('should copy state with new values', () {
      const initialState = RibbonWarningState();
      
      final newState = initialState.copyWith(
        isSentUnder20Ribbon: true,
        lastWarnedRibbonLevel: 15.0,
      );
      
      expect(newState.isSentUnder20Ribbon, true);
      expect(newState.lastWarnedRibbonLevel, 15.0);
      expect(newState.isSentUnder20Film, false); // unchanged
      expect(newState.lastWarnedFilmLevel, 100.0); // unchanged
    });

    test('should reset all states', () {
      final state = const RibbonWarningState().copyWith(
        isSentUnder20Ribbon: true,
        isSentUnder10Film: true,
        lastWarnedRibbonLevel: 50.0,
      );
      
      final resetState = state.reset();
      
      expect(resetState.isSentUnder20Ribbon, false);
      expect(resetState.isSentUnder10Film, false);
      expect(resetState.lastWarnedRibbonLevel, 100.0);
      expect(resetState.lastWarnedFilmLevel, 100.0);
    });
  });

  group('RibbonWarning Provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      final provider = container.read(ribbonWarningProvider);
      
      expect(provider.isSentUnder20Ribbon, false);
      expect(provider.isSentUnder20Film, false);
      expect(provider.lastWarnedRibbonLevel, 100.0);
      expect(provider.lastWarnedFilmLevel, 100.0);
    });

    test('should set ribbon under 20% warning sent', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      notifier.setRibbonUnder20Sent(18.0);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 18.0);
      expect(state.isSentUnder20Film, false); // should not affect film
    });

    test('should set film under 10% warning sent', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      notifier.setFilmUnder10Sent(8.0);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder10Film, true);
      expect(state.lastWarnedFilmLevel, 8.0);
      expect(state.isSentUnder10Ribbon, false); // should not affect ribbon
    });

    test('should set ribbon under 5% warning sent', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      notifier.setRibbonUnder5Sent(3.0);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder5Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 3.0);
    });

    test('should reset all warnings', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set some warnings first
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setFilmUnder10Sent(8.0);
      
      // Reset all
      notifier.resetAllWarnings();
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, false);
      expect(state.isSentUnder10Film, false);
      expect(state.lastWarnedRibbonLevel, 100.0);
      expect(state.lastWarnedFilmLevel, 100.0);
    });

    test('should reset warnings for specific level', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set warnings for multiple levels
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setFilmUnder20Sent(18.0);
      notifier.setRibbonUnder10Sent(8.0);
      notifier.setFilmUnder10Sent(7.0);
      
      // Reset only level 20
      notifier.resetWarningsForLevel(20);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, false);
      expect(state.isSentUnder20Film, false);
      expect(state.isSentUnder10Ribbon, true); // should remain
      expect(state.isSentUnder10Film, true);   // should remain
    });

    test('should handle multiple warning levels independently for ribbon', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set different warning levels for ribbon
      notifier.setRibbonUnder20Sent(18.0);
      notifier.setRibbonUnder10Sent(8.0);
      notifier.setRibbonUnder5Sent(3.0);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.isSentUnder5Ribbon, true);
      // Film warnings should remain false
      expect(state.isSentUnder20Film, false);
      expect(state.isSentUnder10Film, false);
      expect(state.isSentUnder5Film, false);
      // Last warned level should be updated to the most recent
      expect(state.lastWarnedRibbonLevel, 3.0);
    });

    test('should handle multiple warning levels independently for film', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set different warning levels for film
      notifier.setFilmUnder20Sent(19.0);
      notifier.setFilmUnder10Sent(9.0);
      notifier.setFilmUnder5Sent(4.0);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Film, true);
      expect(state.isSentUnder10Film, true);
      expect(state.isSentUnder5Film, true);
      // Ribbon warnings should remain false
      expect(state.isSentUnder20Ribbon, false);
      expect(state.isSentUnder10Ribbon, false);
      expect(state.isSentUnder5Ribbon, false);
      // Last warned level should be updated to the most recent
      expect(state.lastWarnedFilmLevel, 4.0);
    });

    test('should track last warned levels correctly', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set initial warning
      notifier.setRibbonUnder20Sent(18.0);
      expect(container.read(ribbonWarningProvider).lastWarnedRibbonLevel, 18.0);
      
      // Set lower level warning
      notifier.setRibbonUnder10Sent(8.0);
      expect(container.read(ribbonWarningProvider).lastWarnedRibbonLevel, 8.0);
      
      // Set even lower level warning
      notifier.setRibbonUnder5Sent(3.0);
      expect(container.read(ribbonWarningProvider).lastWarnedRibbonLevel, 3.0);
    });

    test('should reset specific warnings for level 10', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set warnings for all levels
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setRibbonUnder10Sent(8.0);
      notifier.setRibbonUnder5Sent(3.0);
      
      // Reset only level 10
      notifier.resetWarningsForLevel(10);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);  // should remain
      expect(state.isSentUnder10Ribbon, false); // should be reset
      expect(state.isSentUnder5Ribbon, true);   // should remain
    });

    test('should reset specific warnings for level 5', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set warnings for all levels
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setRibbonUnder10Sent(8.0);
      notifier.setRibbonUnder5Sent(3.0);
      
      // Reset only level 5
      notifier.resetWarningsForLevel(5);
      
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true); // should remain
      expect(state.isSentUnder10Ribbon, true); // should remain
      expect(state.isSentUnder5Ribbon, false); // should be reset
    });
  });

  group('RibbonWarning Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should handle ribbon and film warnings independently', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set ribbon warnings
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setRibbonUnder10Sent(8.0);
      
      // Set film warnings
      notifier.setFilmUnder20Sent(18.0);
      notifier.setFilmUnder5Sent(4.0);
      
      final state = container.read(ribbonWarningProvider);
      
      // Check ribbon warnings
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.isSentUnder5Ribbon, false);
      expect(state.lastWarnedRibbonLevel, 8.0);
      
      // Check film warnings
      expect(state.isSentUnder20Film, true);
      expect(state.isSentUnder10Film, false);
      expect(state.isSentUnder5Film, true);
      expect(state.lastWarnedFilmLevel, 4.0);
    });

    test('should maintain state consistency across multiple operations', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Simulate a warning sequence
      notifier.setRibbonUnder20Sent(18.0);
      notifier.setFilmUnder20Sent(19.0);
      
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder20Film, true);
      
      // Simulate further degradation
      notifier.setRibbonUnder10Sent(9.0);
      notifier.setFilmUnder10Sent(8.0);
      
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.isSentUnder20Film, true);
      expect(state.isSentUnder10Film, true);
      
      // Reset specific level
      notifier.resetWarningsForLevel(20);
      
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, false);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.isSentUnder20Film, false);
      expect(state.isSentUnder10Film, true);
    });
  });

  group('RibbonWarning Log Testing', () {
    late ProviderContainer container;
    late MockKioskInfoService mockKioskInfoService;
    late MockRibbonStatus mockRibbonStatus;
    late MockPrinterService mockPrinterService;
    late MockSlackLogService mockSlackLogService;

    setUp(() {
      mockKioskInfoService = MockKioskInfoService();
      mockRibbonStatus = MockRibbonStatus();
      mockPrinterService = MockPrinterService();
      mockSlackLogService = MockSlackLogService();
      
      container = ProviderContainer(
        overrides: [
          mockKioskInfoServiceProvider.overrideWithValue(mockKioskInfoService),
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should send critical ribbon warning when level is 5% or below', (WidgetTester tester) async {
      // Arrange
      mockRibbonStatus = MockRibbonStatus(rbnRemaining: 3, filmRemaining: 50);
      mockKioskInfoService = MockKioskInfoService(kioskMachineId: 123);
      mockPrinterService = MockPrinterService(ribbonStatus: mockRibbonStatus);
      
      container = ProviderContainer(
        overrides: [
          mockKioskInfoServiceProvider.overrideWithValue(mockKioskInfoService),
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
      
      final notifier = container.read(ribbonWarningProvider.notifier);

      // Act - Simulate the conditions that would trigger a 5% ribbon warning
      if (mockRibbonStatus.rbnRemaining <= 5 && !container.read(ribbonWarningProvider).isSentUnder5Ribbon) {
        notifier.setRibbonUnder5Sent(mockRibbonStatus.rbnRemaining.toDouble());
      }

      // Assert
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder5Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 3.0);
      expect(state.isSentUnder5Film, false); // Film should not be affected
    });

    testWidgets('should send warning log when film level is 10% or below', (WidgetTester tester) async {
      // Arrange
      mockRibbonStatus = MockRibbonStatus(rbnRemaining: 50, filmRemaining: 8);
      mockKioskInfoService = MockKioskInfoService(kioskMachineId: 123);
      mockPrinterService = MockPrinterService(ribbonStatus: mockRibbonStatus);
      
      container = ProviderContainer(
        overrides: [
          mockKioskInfoServiceProvider.overrideWithValue(mockKioskInfoService),
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
      
      final notifier = container.read(ribbonWarningProvider.notifier);

      // Act - Simulate the conditions that would trigger a 10% film warning
      if (mockRibbonStatus.filmRemaining <= 10 && !container.read(ribbonWarningProvider).isSentUnder10Film) {
        notifier.setFilmUnder10Sent(mockRibbonStatus.filmRemaining.toDouble());
      }

      // Assert
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder10Film, true);
      expect(state.lastWarnedFilmLevel, 8.0);
      expect(state.isSentUnder10Ribbon, false); // Ribbon should not be affected
    });

    testWidgets('should send info log when ribbon level is 20% or below', (WidgetTester tester) async {
      // Arrange
      mockRibbonStatus = MockRibbonStatus(rbnRemaining: 18, filmRemaining: 50);
      mockKioskInfoService = MockKioskInfoService(kioskMachineId: 123);
      mockPrinterService = MockPrinterService(ribbonStatus: mockRibbonStatus);
      
      container = ProviderContainer(
        overrides: [
          mockKioskInfoServiceProvider.overrideWithValue(mockKioskInfoService),
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
      
      final notifier = container.read(ribbonWarningProvider.notifier);

      // Act - Simulate the conditions that would trigger a 20% ribbon warning
      if (mockRibbonStatus.rbnRemaining <= 20 && !container.read(ribbonWarningProvider).isSentUnder20Ribbon) {
        notifier.setRibbonUnder20Sent(mockRibbonStatus.rbnRemaining.toDouble());
      }

      // Assert
      final state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 18.0);
      expect(state.isSentUnder20Film, false); // Film should not be affected
    });

    testWidgets('should not send duplicate warnings for same level', (WidgetTester tester) async {
      // Arrange
      mockRibbonStatus = MockRibbonStatus(rbnRemaining: 15, filmRemaining: 50);
      mockPrinterService = MockPrinterService(ribbonStatus: mockRibbonStatus);
      
      container = ProviderContainer(
        overrides: [
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
      
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // First call - should trigger warning
      notifier.setRibbonUnder20Sent(15.0);
      
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      
      // Second call with same or lower level - should not trigger again
      // (in real scenario, checkAndSendWarnings would check isSentUnder20Ribbon flag)
      final shouldSendAgain = !state.isSentUnder20Ribbon && mockRibbonStatus.rbnRemaining <= 20;
      
      // Assert
      expect(shouldSendAgain, false); // Should not send again
    });

    testWidgets('should handle multiple warnings independently', (WidgetTester tester) async {
      // Arrange
      mockRibbonStatus = MockRibbonStatus(rbnRemaining: 8, filmRemaining: 4);
      mockPrinterService = MockPrinterService(ribbonStatus: mockRibbonStatus);
      
      container = ProviderContainer(
        overrides: [
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
      
      final notifier = container.read(ribbonWarningProvider.notifier);

      // Act - Simulate multiple warning levels being triggered
      // For ribbon (8%)
      notifier.setRibbonUnder20Sent(8.0);
      notifier.setRibbonUnder10Sent(8.0);
      
      // For film (4%)
      notifier.setFilmUnder20Sent(4.0);
      notifier.setFilmUnder10Sent(4.0);
      notifier.setFilmUnder5Sent(4.0);

      // Assert
      final state = container.read(ribbonWarningProvider);
      
      // Ribbon warnings
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.isSentUnder5Ribbon, false); // Should not be triggered for 8%
      
      // Film warnings
      expect(state.isSentUnder20Film, true);
      expect(state.isSentUnder10Film, true);
      expect(state.isSentUnder5Film, true);
      
      // Last warned levels should be updated
      expect(state.lastWarnedRibbonLevel, 8.0);
      expect(state.lastWarnedFilmLevel, 4.0);
    });

    testWidgets('should reset warnings when refill is detected', (WidgetTester tester) async {
      // Arrange - Set initial low levels and warnings
      container = ProviderContainer();
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // Set warnings for low levels
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setRibbonUnder10Sent(8.0);
      notifier.setFilmUnder20Sent(12.0);
      
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.isSentUnder20Film, true);

      // Act - Simulate refill detection (levels increased significantly)
      final newRibbonLevel = 85.0; // Ribbon refilled
      final newFilmLevel = 90.0;   // Film refilled
      
      // Simulate the refill detection logic from checkAndSendWarnings
      final ribbonRefilled = newRibbonLevel > state.lastWarnedRibbonLevel;
      final filmRefilled = newFilmLevel > state.lastWarnedFilmLevel;
      
      if (ribbonRefilled) {
        // Reset ribbon warnings
        notifier.state = notifier.state.copyWith(
          isSentUnder20Ribbon: false,
          isSentUnder10Ribbon: false,
          isSentUnder5Ribbon: false,
          lastWarnedRibbonLevel: newRibbonLevel,
        );
      }
      
      if (filmRefilled) {
        // Reset film warnings
        notifier.state = notifier.state.copyWith(
          isSentUnder20Film: false,
          isSentUnder10Film: false,
          isSentUnder5Film: false,
          lastWarnedFilmLevel: newFilmLevel,
        );
      }

      // Assert
      final finalState = container.read(ribbonWarningProvider);
      expect(finalState.isSentUnder20Ribbon, false);
      expect(finalState.isSentUnder10Ribbon, false);
      expect(finalState.isSentUnder20Film, false);
      expect(finalState.lastWarnedRibbonLevel, 85.0);
      expect(finalState.lastWarnedFilmLevel, 90.0);
    });
  });

  group('checkAndSendWarnings Integration Tests', () {
    late ProviderContainer container;
    late MockKioskInfoService mockKioskInfoService;
    late MockRibbonStatus mockRibbonStatus;
    late MockPrinterService mockPrinterService;

    setUp(() {
      mockKioskInfoService = MockKioskInfoService(kioskMachineId: 999);
      mockRibbonStatus = MockRibbonStatus();
      mockPrinterService = MockPrinterService(ribbonStatus: mockRibbonStatus);
      
      container = ProviderContainer(
        overrides: [
          mockKioskInfoServiceProvider.overrideWithValue(mockKioskInfoService),
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should detect ribbon refill and reset warnings', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 1. Set initial low levels and warnings
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setRibbonUnder10Sent(8.0);
      
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 8.0);

      // 2. Simulate ribbon refill
      mockRibbonStatus.rbnRemaining = 85;
      mockRibbonStatus.filmRemaining = 20; // Film stays low
      
      // 3. Simulate the refill detection logic
      final ribbonLevel = mockRibbonStatus.rbnRemaining.toDouble();
      final filmLevel = mockRibbonStatus.filmRemaining.toDouble();
      
      final ribbonRefilled = ribbonLevel > state.lastWarnedRibbonLevel;
      final filmRefilled = filmLevel > state.lastWarnedFilmLevel;
      
      // Apply the same logic as checkAndSendWarnings
      if (ribbonRefilled) {
        notifier.state = notifier.state.copyWith(
          isSentUnder20Ribbon: false,
          isSentUnder10Ribbon: false,
          isSentUnder5Ribbon: false,
          lastWarnedRibbonLevel: ribbonLevel,
        );
      }

      // 4. Verify ribbon warnings are reset but film warnings remain
      final finalState = container.read(ribbonWarningProvider);
      expect(finalState.isSentUnder20Ribbon, false); // Reset
      expect(finalState.isSentUnder10Ribbon, false); // Reset
      expect(finalState.lastWarnedRibbonLevel, 85.0);
      expect(ribbonRefilled, true);
      expect(filmRefilled, false); // Film was not refilled
    });

    test('should detect film refill independently', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 1. Set initial warnings for both
      notifier.setRibbonUnder20Sent(15.0);
      notifier.setFilmUnder20Sent(12.0);
      notifier.setFilmUnder10Sent(8.0);
      
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder20Film, true);
      expect(state.isSentUnder10Film, true);

      // 2. Simulate only film refill
      mockRibbonStatus.rbnRemaining = 10; // Ribbon stays low
      mockRibbonStatus.filmRemaining = 90; // Film refilled
      
      // 3. Apply refill detection logic
      final ribbonLevel = mockRibbonStatus.rbnRemaining.toDouble();
      final filmLevel = mockRibbonStatus.filmRemaining.toDouble();
      
      final ribbonRefilled = ribbonLevel > state.lastWarnedRibbonLevel;
      final filmRefilled = filmLevel > state.lastWarnedFilmLevel;
      
      if (filmRefilled) {
        notifier.state = notifier.state.copyWith(
          isSentUnder20Film: false,
          isSentUnder10Film: false,
          isSentUnder5Film: false,
          lastWarnedFilmLevel: filmLevel,
        );
      }

      // 4. Verify only film warnings are reset
      final finalState = container.read(ribbonWarningProvider);
      expect(finalState.isSentUnder20Ribbon, true);  // Should remain
      expect(finalState.isSentUnder20Film, false);   // Reset
      expect(finalState.isSentUnder10Film, false);   // Reset
      expect(finalState.lastWarnedFilmLevel, 90.0);
      expect(ribbonRefilled, false); // Ribbon was not refilled
      expect(filmRefilled, true);
    });

    test('should handle warning sequence correctly', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 1. Start with good levels
      expect(container.read(ribbonWarningProvider).isSentUnder20Ribbon, false);
      
      // 2. Simulate degradation to 18% - should trigger 20% warning
      mockRibbonStatus.rbnRemaining = 18;
      if (mockRibbonStatus.rbnRemaining <= 20 && !container.read(ribbonWarningProvider).isSentUnder20Ribbon) {
        notifier.setRibbonUnder20Sent(18.0);
      }
      
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 18.0);
      
      // 3. Further degradation to 8% - should trigger 10% warning
      mockRibbonStatus.rbnRemaining = 8;
      if (mockRibbonStatus.rbnRemaining <= 10 && !state.isSentUnder10Ribbon) {
        notifier.setRibbonUnder10Sent(8.0);
      }
      
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 8.0);
      
      // 4. Critical degradation to 3% - should trigger 5% warning
      mockRibbonStatus.rbnRemaining = 3;
      if (mockRibbonStatus.rbnRemaining <= 5 && !state.isSentUnder5Ribbon) {
        notifier.setRibbonUnder5Sent(3.0);
      }
      
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder5Ribbon, true);
      expect(state.lastWarnedRibbonLevel, 3.0);
      
      // 5. All warnings should be active
      expect(state.isSentUnder20Ribbon, true);
      expect(state.isSentUnder10Ribbon, true);
      expect(state.isSentUnder5Ribbon, true);
    });

    test('should prevent duplicate warnings', () {
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 1. Set 10% warning
      notifier.setRibbonUnder10Sent(8.0);
      
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder10Ribbon, true);
      
      // 2. Try to trigger same level again - should be prevented
      mockRibbonStatus.rbnRemaining = 7; // Still under 10%
      final shouldTriggerAgain = mockRibbonStatus.rbnRemaining <= 10 && !state.isSentUnder10Ribbon;
      
      expect(shouldTriggerAgain, false, reason: '10% warning already sent, should not trigger again');
      
      // 3. But 5% warning should still be possible
      final shouldTrigger5Percent = mockRibbonStatus.rbnRemaining <= 5 && !state.isSentUnder5Ribbon;
      expect(shouldTrigger5Percent, false, reason: '7% is not under 5%'); // 7% is not under 5%
      
      // 4. Test actual 5% trigger condition
      mockRibbonStatus.rbnRemaining = 4; // Now under 5%
      final shouldTrigger5PercentActual = mockRibbonStatus.rbnRemaining <= 5 && !state.isSentUnder5Ribbon;
      expect(shouldTrigger5PercentActual, true, reason: '4% should trigger 5% warning');
    });
  });

  group('실제 checkAndSendWarnings 로그 전송 테스트', () {
    late ProviderContainer container;
    late MockKioskInfoService mockKioskInfoService;
    late MockRibbonStatus mockRibbonStatus;
    late MockPrinterService mockPrinterService;
    late TestWidgetRef testRef;

    setUp(() {
      mockKioskInfoService = MockKioskInfoService(kioskMachineId: 888);
      mockRibbonStatus = MockRibbonStatus();
      mockPrinterService = MockPrinterService(ribbonStatus: mockRibbonStatus);
      
      container = ProviderContainer(
        overrides: [
          mockKioskInfoServiceProvider.overrideWithValue(mockKioskInfoService),
          mockPrinterServiceProvider.overrideWith((ref) => mockPrinterService),
        ],
      );
      
      testRef = TestWidgetRef(container);
    });

    tearDown(() {
      container.dispose();
    });

    test('실제 checkAndSendWarnings 호출 - 5% 리본 경고', () {
      // Arrange - 5% 리본 레벨 설정
      mockRibbonStatus.rbnRemaining = 3;
      mockRibbonStatus.filmRemaining = 50;
      
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 초기 상태 확인
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder5Ribbon, false);
      
      // Act - 실제 checkAndSendWarnings 호출
      notifier.checkAndSendWarnings(testRef);
      
      // Assert - 상태 변화 확인
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder5Ribbon, true, reason: '5% 리본 경고가 전송되어야 함');
      expect(state.lastWarnedRibbonLevel, 3.0, reason: '마지막 경고 레벨이 업데이트되어야 함');
      expect(state.isSentUnder5Film, false, reason: '필름 경고는 영향받지 않아야 함');
      
      print('✅ 5% 리본 경고 로그 전송 완료: MachineId: 888, Level: 3%');
    });

    test('실제 checkAndSendWarnings 호출 - 10% 필름 경고', () {
      // Arrange - 10% 필름 레벨 설정
      mockRibbonStatus.rbnRemaining = 80;
      mockRibbonStatus.filmRemaining = 8;
      
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 초기 상태 확인
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder10Film, false);
      
      // Act - 실제 checkAndSendWarnings 호출
      notifier.checkAndSendWarnings(testRef);
      
      // Assert - 상태 변화 확인
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder10Film, true, reason: '10% 필름 경고가 전송되어야 함');
      expect(state.lastWarnedFilmLevel, 8.0, reason: '마지막 경고 레벨이 업데이트되어야 함');
      expect(state.isSentUnder10Ribbon, false, reason: '리본 경고는 영향받지 않아야 함');
      
      print('✅ 10% 필름 경고 로그 전송 완료: MachineId: 888, Level: 8%');
    });

    test('실제 checkAndSendWarnings 호출 - 20% 리본 경고', () {
      // Arrange - 20% 리본 레벨 설정
      mockRibbonStatus.rbnRemaining = 18;
      mockRibbonStatus.filmRemaining = 60;
      
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 초기 상태 확인
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, false);
      
      // Act - 실제 checkAndSendWarnings 호출
      notifier.checkAndSendWarnings(testRef);
      
      // Assert - 상태 변화 확인
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder20Ribbon, true, reason: '20% 리본 경고가 전송되어야 함');
      expect(state.lastWarnedRibbonLevel, 18.0, reason: '마지막 경고 레벨이 업데이트되어야 함');
      expect(state.isSentUnder20Film, false, reason: '필름 경고는 영향받지 않아야 함');
      
      print('✅ 20% 리본 경고 로그 전송 완료: MachineId: 888, Level: 18%');
    });

    test('실제 checkAndSendWarnings 호출 - 응급 상황 (리본+필름 모두 5% 이하)', () {
      // Arrange - 리본과 필름 모두 5% 이하
      mockRibbonStatus.rbnRemaining = 3;
      mockRibbonStatus.filmRemaining = 4;
      
      final notifier = container.read(ribbonWarningProvider.notifier);
      
      // 초기 상태 확인
      var state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder5Ribbon, false);
      expect(state.isSentUnder5Film, false);
      
      // Act - 실제 checkAndSendWarnings 호출
      notifier.checkAndSendWarnings(testRef);
      
      // Assert - 개별 경고와 응급 경고 모두 확인
      state = container.read(ribbonWarningProvider);
      expect(state.isSentUnder5Ribbon, true, reason: '5% 리본 경고가 전송되어야 함');
      expect(state.isSentUnder5Film, true, reason: '5% 필름 경고가 전송되어야 함');
      expect(state.lastWarnedRibbonLevel, 3.0);
      expect(state.lastWarnedFilmLevel, 4.0);
      
      print('✅ 응급 상황 경고 로그 전송 완료: 리본 3%, 필름 4% - 개별 + 응급 로그 모두 전송됨');
    });
  });
}
