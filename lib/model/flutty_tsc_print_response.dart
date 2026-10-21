/// A sealed class representing the outcome of a print operation.
sealed class FluttyTscPrintResponse {
  const FluttyTscPrintResponse();
}

/// Represents a successful print operation.
final class PrintSuccessResponse extends FluttyTscPrintResponse {
  /// An optional human-readable message describing the outcome.
  final String? message;

  /// Creates a success response with an optional [message].
  const PrintSuccessResponse(this.message);

  @override
  String toString() => 'PrintSuccess(message: $message)';
}

/// Represents an error due to invalid parameters in the request.
final class PrintBadParamResponse extends FluttyTscPrintResponse {
  /// A human-readable message describing the invalid parameter.
  final String message;

  /// Creates a bad-parameter response with a [message].
  const PrintBadParamResponse(this.message);

  @override
  String toString() => 'PrintBadParam(message: $message)';
}

/// Represents an error that occurred during communication with the printer.
final class PrintErrorResponse extends FluttyTscPrintResponse {
  /// An optional human-readable message describing the error.
  final String? message;

  /// Creates an error response with an optional [message].
  const PrintErrorResponse(this.message);

  @override
  String toString() => 'PrintError(message: $message)';
}
