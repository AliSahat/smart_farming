import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'SmartFarming';

  // Log levels
  static const int VERBOSE = 0;
  static const int DEBUG = 1;
  static const int INFO = 2;
  static const int WARN = 3;
  static const int ERROR = 4;

  // Current log level (change to control verbosity)
  static int _currentLevel = DEBUG;

  static void v(String message, {String? tag}) {
    _log(VERBOSE, message, tag);
  }

  static void d(String message, {String? tag}) {
    _log(DEBUG, message, tag);
  }

  static void i(String message, {String? tag}) {
    _log(INFO, message, tag);
  }

  static void w(String message, {String? tag}) {
    _log(WARN, message, tag);
  }

  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(ERROR, message, tag, error, stackTrace);
  }

  static void _log(
    int level,
    String message,
    String? tag, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level < _currentLevel) return;

    final tagDisplay = tag != null ? '[$tag]' : '[$_tag]';
    final levelStr = _getLevelString(level);
    final logMessage = '$tagDisplay $levelStr: $message';

    if (kDebugMode) {
      print(logMessage);
      if (error != null) print('ERROR: $error');
      if (stackTrace != null) print('STACK TRACE: $stackTrace');
    }
  }

  static String _getLevelString(int level) {
    switch (level) {
      case VERBOSE:
        return 'V';
      case DEBUG:
        return 'D';
      case INFO:
        return 'I';
      case WARN:
        return 'W';
      case ERROR:
        return 'E';
      default:
        return '?';
    }
  }

  // For debugging JSON responses
  static void logJson(dynamic json, {String? tag}) {
    // Format JSON for better readability
    final formattedJson = json.toString();
    d('JSON Response: $formattedJson', tag: tag ?? 'API');
  }
}
