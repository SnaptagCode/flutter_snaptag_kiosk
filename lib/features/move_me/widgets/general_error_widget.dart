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
    logger.e('Error occurred', error: e);
    if (e is ServerException) {
      return '${e.serverError.res.message}\n${e.serverError.statusCode}';
    } else if (e is DioException) {
      return 'DioException 발생: ${e.message}';
    } else if (e != null) {
      return '알 수 없는 오류가 발생했습니다.\n${e.toString()}';
    }
    return '오류가 발생했습니다.';
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _getErrorMessage(exception);

    return Column(
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry, // onRetry 안전하게 호출
          child: const Text('재시도'),
        ),
      ],
    );
  }
}
