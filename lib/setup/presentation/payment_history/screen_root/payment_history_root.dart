import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/payment_history/notifier/payment_history_action.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/payment_history/notifier/payment_history_notifier.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/payment_history/notifier/payment_history_state.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/payment_history/screen/payment_history_screen.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/payment_history/screen/payment_history_screen_state.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PaymentHistoryRoot extends ConsumerStatefulWidget {
  const PaymentHistoryRoot({super.key});

  @override
  ConsumerState<PaymentHistoryRoot> createState() => _PaymentHistoryRootState();
}

class _PaymentHistoryRootState extends ConsumerState<PaymentHistoryRoot> {
  // 이전에 로드된 데이터를 유지해 loading 중에도 화면이 비지 않도록 함
  OrderListResponse? _lastOrders;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(paymentHistoryNotifierProvider.notifier);
    final notifierState = ref.watch(paymentHistoryNotifierProvider);

    // 데이터가 있는 상태에서만 _lastOrders 갱신
    switch (notifierState) {
      case PaymentHistoryStateLoaded(:final orders):
      case PaymentHistoryStateAwaitingRefundConfirmation(:final orders):
      case PaymentHistoryStateRefundSuccess(:final orders):
        _lastOrders = orders;
      default:
        break;
    }

    final screenState = switch (notifierState) {
      // loading 중에는 이전 데이터 유지 (초기 로딩이면 null → inline spinner)
      PaymentHistoryStateLoading() => PaymentHistoryScreenState(orders: _lastOrders),
      PaymentHistoryStateLoaded(:final orders) => PaymentHistoryScreenState(orders: orders),
      PaymentHistoryStateAwaitingRefundConfirmation(:final orders) =>
        PaymentHistoryScreenState(orders: orders),
      PaymentHistoryStateRefundSuccess(:final orders) => PaymentHistoryScreenState(orders: orders),
      PaymentHistoryStateFailure(:final orders, :final failure) => PaymentHistoryScreenState(
          orders: orders ?? _lastOrders,
          hasLoadError: failure is PaymentHistoryFailureLoadFailed && _lastOrders == null,
        ),
    };

    ref.listen<PaymentHistoryState>(paymentHistoryNotifierProvider, (prev, state) async {
      switch (state) {
        case PaymentHistoryStateLoading():
          // 이전에 데이터가 있었을 때만 overlay 표시 (페이지네이션/환불)
          // 초기 로딩은 body의 inline spinner가 처리
          final hadData = prev is PaymentHistoryStateLoaded ||
              prev is PaymentHistoryStateAwaitingRefundConfirmation ||
              prev is PaymentHistoryStateRefundSuccess;
          if (hadData && !context.loaderOverlay.visible) context.loaderOverlay.show();

        case PaymentHistoryStateLoaded():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();

        case PaymentHistoryStateAwaitingRefundConfirmation():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (!context.mounted) return;

          final confirmed1 = await DialogHelper.showSetupDialog(
            context,
            title: '환불을 진행합니다.',
            showCancelButton: true,
          );
          if (!context.mounted) return;
          if (!confirmed1) {
            notifier.onAction(const PaymentHistoryAction.cancelRefund());
            return;
          }

          final confirmed2 = await DialogHelper.showSetupDialog(
            context,
            title: '결제한 카드를 삽입해 주세요.',
            cancelButtonText: '환불 취소',
            confirmButtonText: '환불 진행',
            showCancelButton: true,
          );
          if (!context.mounted) return;
          notifier.onAction(
            confirmed2
                ? const PaymentHistoryAction.confirmRefund()
                : const PaymentHistoryAction.cancelRefund(),
          );

        case PaymentHistoryStateRefundSuccess():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (!context.mounted) return;
          await DialogHelper.showRefundSuccessDialog(context);
          if (!context.mounted) return;
          notifier.onAction(const PaymentHistoryAction.acknowledgeResult());

        case PaymentHistoryStateFailure(:final failure):
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (!context.mounted) return;
          if (failure is PaymentHistoryFailureRefundFailed) {
            await DialogHelper.showRefundFailDialog(context);
            if (!context.mounted) return;
            notifier.onAction(const PaymentHistoryAction.cancelRefund());
          }
      }
    });

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Pretendard'),
      ),
      child: LoaderOverlay(
        overlayWidgetBuilder: (_) => Center(
          child: SizedBox(
            width: 350.h,
            height: 350.h,
            child: CircularProgressIndicator(strokeWidth: 15.h),
          ),
        ),
        child: PaymentHistoryScreen(
          state: screenState,
          onAction: notifier.onAction,
          onBack: () async {
            final result = await DialogHelper.showSetupDialog(
              context,
              title: '메인페이지로 이동합니다.',
              showCancelButton: true,
            );
            if (result && context.mounted) Navigator.pop(context);
          },
          onHome: () => HomeRouteData().go(context),
        ),
      ),
    );
  }
}
