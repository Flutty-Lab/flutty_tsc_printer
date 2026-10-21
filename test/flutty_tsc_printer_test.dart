import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_tsc_printer/flutty_tsc_printer.dart';

void main() {
  ServerSocket? server;
  final received = <List<int>>[];

  /// Starts a fake printer on loopback. If [reply] is given, every accepted
  /// socket receives it as a response; the socket is otherwise kept open and
  /// silent until the client disconnects.
  Future<int> startPrinter({String? reply}) async {
    final bound = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    bound.listen((socket) {
      socket.listen(received.add);
      if (reply != null) socket.write(reply);
    });
    server = bound;
    return bound.port;
  }

  /// Returns a port on which nothing listens.
  Future<int> deadPort() async {
    final ephemeral = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = ephemeral.port;
    await ephemeral.close();
    return port;
  }

  tearDown(() async {
    await server?.close();
    server = null;
    received.clear();
  });

  FluttyTscPrintRequest printRequest(
    int port, {
    int writeTimeout = 500,
    int readTimeout = 300,
  }) =>
      FluttyTscPrintRequest(
        ipAddress: '127.0.0.1',
        port: port,
        writeTimeout: writeTimeout,
        readTimeout: readTimeout,
        commands: [
          TscSize(width: 76, height: 25),
          TscText(x: 10, y: 10, font: '3', content: 'Hello World'),
          TscPrint(quantity: 1),
        ],
      );

  test('empty command list returns a bad param response', () async {
    final result = await FluttyTscPrinter.sendTscCommands(
      FluttyTscPrintRequest(ipAddress: '127.0.0.1', commands: []),
    );

    expect(result, isA<PrintBadParamResponse>());
  });

  test('sendTscCommands writes the commands and succeeds on silence', () async {
    final port = await startPrinter();

    final result = await FluttyTscPrinter.sendTscCommands(printRequest(port));

    expect(result, isA<PrintSuccessResponse>());
    expect(
      String.fromCharCodes(received.expand((c) => c)),
      'SIZE 76.0 mm, 25.0 mm\r\n'
      'TEXT 10,10,"3",0,1,1,"Hello World"\r\n'
      'PRINT 1,1\r\n',
    );
  });

  test('a printer response is surfaced as an error', () async {
    final port = await startPrinter(reply: 'OUT OF PAPER\r\n');

    final result = await FluttyTscPrinter.sendTscCommands(printRequest(port));

    expect(result, isA<PrintErrorResponse>());
    expect((result as PrintErrorResponse).message, contains('OUT OF PAPER'));
  });

  test('an unreachable printer returns an error response', () async {
    final result = await FluttyTscPrinter.sendTscCommands(
      printRequest(await deadPort()),
    );

    expect(result, isA<PrintErrorResponse>());
  });

  test('testConnection returns true when the printer accepts', () async {
    final port = await startPrinter();

    final reachable = await FluttyTscPrinter.testConnection(
      FluttyTscTestConnectionRequest(ipAddress: '127.0.0.1', port: port),
    );

    expect(reachable, isTrue);
  });

  test('testConnection throws when the printer is unreachable', () async {
    await expectLater(
      FluttyTscPrinter.testConnection(
        FluttyTscTestConnectionRequest(
          ipAddress: '127.0.0.1',
          port: await deadPort(),
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });
}
