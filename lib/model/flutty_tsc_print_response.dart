/// A sealed class representing the outcome of a print operation.
sealed class FluttyTscPrintResponse {
  const FluttyTscPrintResponse();
}

/// Represents a successful print operation.
final class PrintSuccessResponse extends FluttyTscPrintResponse {
  final String? message;
  const PrintSuccessResponse(this.message);

  @override
  String toString() => 'PrintSuccess(message: $message)';
}

/// Represents an error due to invalid parameters in the request.
final class PrintBadParamResponse extends FluttyTscPrintResponse {
  final String message;
  const PrintBadParamResponse(this.message);

  @override
  String toString() => 'PrintBadParam(message: $message)';
}

/// Represents an error that occurred during communication with the printer.
final class PrintErrorResponse extends FluttyTscPrintResponse {
  final String? message;
  const PrintErrorResponse(this.message);

  @override
  String toString() => 'PrintError(message: $message)';
}
