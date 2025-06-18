class DatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DatabaseException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'DatabaseException: $message';
}

class DatabaseExceptionHandler {
  static DatabaseException handle(dynamic error) {
    if (error is DatabaseException) {
      return error;
    }

    String message = 'Database operation failed';
    String? code;

    if (error.toString().contains('UNIQUE constraint failed')) {
      message = 'Data with the same key already exists';
      code = 'DUPLICATE_KEY';
    } else if (error.toString().contains('FOREIGN KEY constraint failed')) {
      message = 'Related data not found';
      code = 'FOREIGN_KEY_VIOLATION';
    } else if (error.toString().contains('no such table')) {
      message = 'Database table not found';
      code = 'TABLE_NOT_FOUND';
    }

    return DatabaseException(message, code: code, originalError: error);
  }
}
