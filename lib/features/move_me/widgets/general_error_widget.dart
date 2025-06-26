import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class GeneralErrorWidget extends StatelessWidget {
  const GeneralErrorWidget({
    super.key,
    this.exception,
    this.onRetry,
  });

  final Exception? exception;
  final void Function()? onRetry;

  String _getErrorMessage(Exception? e) {
    logger.e('Error occurred $e');
    if (e is ServerException) {
      return '${e.serverError.res.message}\n\n${e.serverError.statusCode}';
    } else if (e is DioException) {
      return '${e.message}';
    }
    return '오류가 발생했습니다.\n관리자에게 문의해주세요.';
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _getErrorMessage(exception);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: context.typography.kioskAlert1B,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry, // onRetry 안전하게 호출
            child: const Text('재시도'),
          ),
        ],
      ),
    );
  }
}
