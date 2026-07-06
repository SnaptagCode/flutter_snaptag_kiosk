import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/sound/sound_manager.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/payment_history_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/setup_refund_process_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  int _lastRefundAmount = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen(setupRefundProcessProvider, (prev, next) {
      next.whenOrNull(
        error: (error, stack) async {
          context.loaderOverlay.hide();
          await DialogHelper.showRefundFailDialog(context);
        },
        data: (response) async {
          context.loaderOverlay.hide();
          if (response != null && response.code == 1) {
            await DialogHelper.showRefundSuccessDialog(context,
                amount: _lastRefundAmount);
          } else if (response != null) {
            await DialogHelper.showRefundFailDialog(context);
          }
        },
      );
    });
    final ordersPage = ref.watch(ordersPageProvider());

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Pretendard',
            ),
      ),
      child: LoaderOverlay(
        overlayWidgetBuilder: (dynamic progress) {
          return Center(
            child: SizedBox(
              width: 350.h,
              height: 350.h,
              child: CircularProgressIndicator(
                strokeWidth: 15.h,
              ),
            ),
          );
        },
        child: Scaffold(
          backgroundColor: Color(0xFFF2F2F2),
          appBar: AppBar(
            leading: IconButton(
              padding: EdgeInsets.only(left: 30.w),
              icon: SvgPicture.asset(SnaptagSvg.arrowBack),
              onPressed: () async {
                final result = await DialogHelper.showSetupDialog(
                  context,
                  title: '메인페이지로 이동합니다.',
                  showCancelButton: true,
                );
                if (result) {
                  Navigator.pop(context);
                }
              },
            ),
            title: const Text('출력 내역'),
            actions: [
              // IconButton(
              //   icon: Icon(Icons.description_outlined, size: 24.sp),
              //   tooltip: '단말기 로그 전송',
              //   onPressed: _showLogFileDialog,
              // ),
              //키오스크에서 실행시켜보고 사이즈 조절 필요시 SizedBox로
              IconButton(
                padding: EdgeInsets.only(left: 30.w),
                icon: SvgPicture.asset(SnaptagSvg.home),
                onPressed: () async {
                  HomeRouteData().go(context);
                },
              ),
            ],
          ),
          body: ordersPage.when(
            data: (response) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 130.w,
                  ),
                  SizedBox(
                    width: 438.w,
                    child: DateWidget(),
                  ),
                  SizedBox(
                    height: 60.w,
                  ),
                  DataTable(
                    columnSpacing: 15.0,
                    horizontalMargin: 0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    headingTextStyle: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 18.sp,
                    ),
                    headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Color(0xFFF6F7F8),
                    ),
                    dataTextStyle: TextStyle(
                      color: Color(0xFF414448),
                      fontSize: 16.sp,
                    ),
                    columns: columns,
                    rows: response.list.map((order) {
                      return DataRow(
                        color: WidgetStateColor.resolveWith(
                            (states) => Colors.white),
                        cells: [
                          DataCell(
                            Center(
                              child: Text(
                                order.completedAt != null
                                    ? DateFormat('yyyy.MM.dd HH:mm').format(
                                        order.completedAt!,
                                      )
                                    : '',
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                order.eventName.length > 20
                                    ? '${order.eventName.substring(0, 20)}...'
                                    : order.eventName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                                child: Text(NumberFormat('#,###')
                                    .format(order.amount.toInt()))),
                          ),
                          DataCell(
                            Center(
                                child: Text(_getOrderState(order.orderStatus))),
                          ),
                          DataCell(
                            Center(child: _getRefundWidget(context, order)),
                          ),
                          DataCell(
                            Center(
                                child: Text(isPrinted(order.printedStatus)
                                    ? 'O'
                                    : 'X')),
                          ),
                          DataCell(
                            Center(child: Text(order.photoAuthNumber)),
                          ),
                          DataCell(
                            Center(child: Text(order.paymentAuthNumber ?? '')),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  PaginationControls(
                    currentPage: response.paging.currentPage,
                    totalPages:
                        (response.paging.totalCount / response.paging.pageSize)
                            .ceil(),
                    onPageChanged: (newPage) {
                      ref.read(ordersPageProvider().notifier).goToPage(newPage);
                    },
                  ),
                ],
              );
            },
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading orders...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            error: (error, stack) => GeneralErrorWidget(
              exception: error as Exception,
              onRetry: () => ref.refresh(ordersPageProvider()),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> get columns {
    return const [
      DataColumn(
        label: Text('일자'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('이벤트명'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('결제 금액'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('결제 상태'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('환불 상태'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('출력 상태'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('인증번호'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
      DataColumn(
        label: Text('결제 승인번호'),
        headingRowAlignment: MainAxisAlignment.center,
      ),
    ];
  }

  bool isPrinted(PrintedStatus? printed) {
    if (printed == null) {
      return false;
    }
    switch (printed) {
      case PrintedStatus.pending:
      case PrintedStatus.started:
      case PrintedStatus.failed:
      case PrintedStatus.refunded_before_printed:
      case PrintedStatus.refunded_failed_before_printed:
        return false;
      case PrintedStatus.completed:
      case PrintedStatus.refunded_after_printed:
      case PrintedStatus.refunded_failed_after_printed:
        return true;
    }
  }

  String _getOrderState(OrderStatus order) {
    switch (order) {
      case OrderStatus.pending:
        return '결제 대기';
      case OrderStatus.failed:
        return '결제 실패';
      case OrderStatus.completed:
      case OrderStatus.refunded:
      case OrderStatus.refunded_failed:
      case OrderStatus.refunded_failed_before_printed:
        return '결제 완료';
    }
  }

  // Future<void> _showLogFileDialog() async {
  //   final dir = Directory(r'C:\KSCAT\ksnetcomm');
  //   if (!await dir.exists()) {
  //     if (!mounted) return;
  //     await DialogHelper.showSetupDialog(
  //       context,
  //       title: '로그 경로를 찾을 수 없습니다.\nC:\\KSCAT\\ksnetcomm',
  //     );
  //     return;
  //   }

  //   final files = dir
  //       .listSync()
  //       .whereType<File>()
  //       .toList()
  //     ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

  //   if (!mounted) return;

  //   if (files.isEmpty) {
  //     await DialogHelper.showSetupDialog(context, title: 'txt 로그 파일이 없습니다.');
  //     return;
  //   }

  //   final selectedFile = await showDialog<File>(
  //     context: context,
  //     builder: (ctx) => _LogFileListDialog(files: files),
  //   );
  //   if (selectedFile == null) return;

  //   if (!mounted) return;
  //   final fileName = selectedFile.uri.pathSegments.last;
  //   final confirm = await DialogHelper.showSetupDialog(
  //     context,
  //     title: '$fileName\n파일을 서버로 전송합니다.',
  //     showCancelButton: true,
  //   );
  //   if (!confirm) return;

  //   if (!mounted) return;
  //   context.loaderOverlay.show();
  //   try {
  //     final bytes = await selectedFile.readAsBytes();
  //     final content = cp949.decode(bytes, allowInvalid: true);
  //     final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
  //     await ref.read(kioskRepositoryProvider).sendKioskLog(
  //           machineId: machineId,
  //           title: fileName,
  //           content: content,
  //         );
  //     if (!mounted) return;
  //     context.loaderOverlay.hide();
  //     await DialogHelper.showSetupDialog(context, title: '로그 전송이 완료되었습니다.');
  //   } catch (e) {
  //     if (!mounted) return;
  //     context.loaderOverlay.hide();
  //     await DialogHelper.showSetupDialog(context, title: '로그 전송에 실패했습니다.\n$e');
  //   }
  // }

  TextButton _getRefundWidget(BuildContext context, OrderEntity order) {
    switch (order.orderStatus) {
      case OrderStatus.pending:
      case OrderStatus.failed:
        return TextButton(
          onPressed: null,
          child: Text(
            '-',
            style: TextStyle(
              color: Color(0xFF414448),
              fontSize: 16.sp,
            ),
          ),
        );
      case OrderStatus.refunded:
        // 환불 상태 판정은 orderStatus 기준으로 한다. (printedStatus와 불일치 케이스 방지)
        return TextButton(
          onPressed: null,
          child: Text(
            '환불 완료',
            style: TextStyle(
              color: Color(0xFF414448),
              fontSize: 16.sp,
            ),
          ),
        );
      case OrderStatus.refunded_failed:
      case OrderStatus.refunded_failed_before_printed:
        return TextButton(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFFF333F),
                ),
              ),
            ),
            child: Text(
              '환불 실패',
              style: TextStyle(
                color: Color(0xFFFF333F),
                fontSize: 16.sp,
              ),
            ),
          ),
          onPressed: () async {
            context.loaderOverlay.show();
            final result1 = await DialogHelper.showSetupDialog(
              context,
              title: '환불을 진행합니다.',
              showCancelButton: true,
            );
            if (!result1) {
              context.loaderOverlay.hide();
              return;
            }
            final result2 = await DialogHelper.showSetupDialog(
              context,
              title: '결제한 카드를 삽입해 주세요.',
              cancelButtonText: '환불 취소',
              confirmButtonText: '환불 진행',
              showCancelButton: true,
            );
            if (result2) {
              _lastRefundAmount = order.amount.toInt();
              await ref
                  .read(setupRefundProcessProvider.notifier)
                  .startRefund(order);
              context.loaderOverlay.hide();
            } else {
              context.loaderOverlay.hide();
            }
          },
        );
      case OrderStatus.completed:
        return TextButton(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF9D9D9D),
                ),
              ),
            ),
            child: Text(
              '환불',
              style: TextStyle(
                color: Color(0xFF9D9D9D),
                fontSize: 16.sp,
              ),
            ),
          ),
          onPressed: () async {
            context.loaderOverlay.show();
            await SoundManager().playSound();
            final result1 = await DialogHelper.showSetupDialog(
              context,
              title: '환불을 진행합니다.',
              showCancelButton: true,
            );
            if (!result1) {
              context.loaderOverlay.hide();
              return;
            }
            final result2 = await DialogHelper.showSetupDialog(
              context,
              title: '결제한 카드를 삽입해 주세요.',
              cancelButtonText: '환불 취소',
              confirmButtonText: '환불 진행',
              showCancelButton: true,
            );
            if (result2) {
              _lastRefundAmount = order.amount.toInt();
              await ref
                  .read(setupRefundProcessProvider.notifier)
                  .startRefund(order);
              context.loaderOverlay.hide();
            } else {
              context.loaderOverlay.hide();
            }
          },
        );
    }
  }
}

class DateWidget extends StatelessWidget {
  const DateWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat('yyyy.MM.dd')
              .format(DateTime.now().subtract(const Duration(days: 14))),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '-',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          DateFormat('yyyy.MM.dd').format(DateTime.now()),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// PaginationControls 위젯은 이전과 동일
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> pageButtons() {
      List<Widget> buttons = [];
      int startPage =
          (currentPage - 5).clamp(1, totalPages > 10 ? totalPages - 9 : 1);
      int endPage = (startPage + 9).clamp(startPage, totalPages);

      for (int i = startPage; i <= endPage; i++) {
        buttons.add(
          ActionChip(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            labelPadding: EdgeInsets.zero,
            label: Text(
              i.toString(),
              style: TextStyle(
                color: i == currentPage ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            backgroundColor:
                i == currentPage ? Color(0xFFA671EA) : Color(0xFFF2F2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.transparent),
            ),
            onPressed: () => onPageChanged(i),
          ),
        );
      }
      return buttons;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First page button
            InkWell(
              onTap: currentPage > 1 ? () => onPageChanged(1) : null,
              child: const Icon(Icons.keyboard_double_arrow_left_sharp),
            ),
            const SizedBox(width: 8),
            // Previous page button
            InkWell(
              onTap:
                  currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              child: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 8),
            // Page buttons
            ...pageButtons(),
            const SizedBox(width: 8),
            // Next page button
            InkWell(
              onTap: currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              child: const Icon(Icons.chevron_right),
            ),
            const SizedBox(width: 8),
            // Last page button
            InkWell(
              onTap: currentPage < totalPages
                  ? () => onPageChanged(totalPages)
                  : null,
              child: const Icon(Icons.keyboard_double_arrow_right_sharp),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogFileListDialog extends StatelessWidget {
  final List<File> files;
  const _LogFileListDialog({required this.files});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('로그 파일 선택', style: TextStyle(fontSize: 20.sp)),
      content: SizedBox(
        width: 500.w,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: files.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final file = files[i];
            final name = file.uri.pathSegments.last;
            final modified =
                DateFormat('yyyy.MM.dd HH:mm').format(file.lastModifiedSync());
            return ListTile(
              title: Text(name, style: TextStyle(fontSize: 16.sp)),
              subtitle: Text(modified,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
              onTap: () => Navigator.pop(ctx, file),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: TextStyle(fontSize: 16.sp)),
        ),
      ],
    );
  }
}
