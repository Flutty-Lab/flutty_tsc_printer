import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutty_tsc_printer/model/flutty_tsc_print_request.dart';
import 'package:flutty_tsc_printer/model/flutty_tsc_test_connection_request.dart';
import 'package:flutty_tsc_printer/model/flutty_tsc_print_response.dart';

export 'package:flutty_tsc_printer/model/flutty_tsc_print_request.dart';
export 'package:flutty_tsc_printer/model/flutty_tsc_print_response.dart';
export 'package:flutty_tsc_printer/model/flutty_tsc_test_connection_request.dart';

/// The main class for interacting with the TSC printer.
///
/// The printer is driven directly over a TCP socket (`dart:io`), which makes
/// the package platform-agnostic: no native plugin code is required.
class FluttyTscPrinter {
  static const Duration _connectTimeout = Duration(seconds: 3);

  /// Sends a generic print request to the printer.
  ///
  /// This method takes a [FluttyTscPrintRequest] object, which contains
  /// the printer's IP address, port, and a list of [TscCommand] objects.
  /// The commands are serialized and written to the socket.
  ///
  /// TSC printers do not answer to print jobs, so a silent socket within
  /// [FluttyTscPrintRequest.writeTimeout] is a success. Any bytes coming back
  /// (terminated by `\r\n`) are treated as an error message from the printer.
  static Future<FluttyTscPrintResponse> sendTscCommands(
    FluttyTscPrintRequest request,
  ) async {
    if (request.commands.isEmpty) {
      const message =
          'Command list must not be empty and must end with a TscPrint command.';
      return const PrintBadParamResponse(message);
    }

    Socket? socket;
    try {
      socket = await Socket.connect(
        request.ipAddress,
        request.port,
        timeout: _connectTimeout,
      );
      socket.add(utf8.encode(request.commandsString));
      await socket.flush().timeout(
            Duration(milliseconds: request.writeTimeout),
          );
      final response = await _readResponse(
        socket,
        startTimeout: Duration(milliseconds: request.writeTimeout),
        endTimeout: Duration(milliseconds: request.readTimeout),
      );
      if (response == null) {
        return const PrintSuccessResponse('Success printing');
      }
      return PrintErrorResponse('Printer returned an error: $response');
    } on SocketException catch (e) {
      return PrintErrorResponse(e.message);
    } on TimeoutException catch (e) {
      return PrintErrorResponse(e.message);
    } catch (e) {
      return PrintErrorResponse(e.toString());
    } finally {
      socket?.destroy();
    }
  }

  /// Opens a TCP connection to the printer and closes it immediately.
  ///
  /// Returns `true` when the printer accepts the connection, throws an
  /// [Exception] carrying the error message otherwise.
  static Future<bool> testConnection(
    FluttyTscTestConnectionRequest request,
  ) async {
    try {
      final socket = await Socket.connect(
        request.ipAddress,
        request.port,
        timeout: _connectTimeout,
      );
      await socket.close();
      return true;
    } catch (e) {
      throw Exception(
        'Failed to connect to printer on ${request.ipAddress}:${request.port} ($e)',
      );
    }
  }

  /// Reads the printer response, if any.
  ///
  /// Returns `null` when nothing arrives within [startTimeout]. Once data
  /// flows, waits for the `\r\n` terminator with [endTimeout] of extra grace;
  /// data received without a terminator is returned as-is after the grace
  /// period or when the printer closes the connection.
  static Future<String?> _readResponse(
    Socket socket, {
    required Duration startTimeout,
    required Duration endTimeout,
  }) async {
    final buffer = BytesBuilder(copy: false);
    final result = Completer<String?>();
    Timer? timer;

    String? decode() =>
        buffer.isEmpty ? null : latin1.decode(buffer.toBytes()).trim();

    void complete(String? value) {
      if (!result.isCompleted) result.complete(value);
    }

    void armTimer(Duration duration, String? Function() onFire) {
      timer?.cancel();
      timer = Timer(duration, () => complete(onFire()));
    }

    armTimer(startTimeout, () => null);

    final subscription = socket.listen(
      (chunk) {
        buffer.add(chunk);
        final bytes = buffer.toBytes();
        final n = bytes.length;
        if (n >= 2 && bytes[n - 2] == 0x0D && bytes[n - 1] == 0x0A) {
          complete(decode());
        } else {
          armTimer(endTimeout, decode);
        }
      },
      onDone: () => complete(decode()),
      onError: (_) => complete(null),
    );
    try {
      return await result.future;
    } finally {
      timer?.cancel();
      await subscription.cancel();
    }
  }
}
