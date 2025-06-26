import 'package:logger/logger.dart';

/// 로그 클래스 호출
///
/// ```dart
/// logger.d('Log message with 2 methods');
/// logger.e('Error! Something bad happened', 'Test Error');
/// ```
var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.none // Should each log print contain a timestamp
      ),
);

/// 로그 클래스 호출(표시할 메서드 0)
///
/// ```dart
/// loggerNoStack.i('Info message');
/// loggerNoStack.w('Just a warning!');
/// loggerNoStack.v({'key': 5, 'value': 'something'});
/// ```
var simpleLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
    noBoxingByDefault: true,
  ),
);
