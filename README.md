# flutty_tsc_printer

[![pub package](https://img.shields.io/pub/v/flutty_tsc_printer.svg)](https://pub.dev/packages/flutty_tsc_printer)
[![pub points](https://img.shields.io/pub/points/flutty_tsc_printer)](https://pub.dev/packages/flutty_tsc_printer/score)
[![likes](https://img.shields.io/pub/likes/flutty_tsc_printer)](https://pub.dev/packages/flutty_tsc_printer/score)

Flutter package to drive **TSC label printers** over TCP/IP using TSPL commands.

- Build a label as a typed list of TSPL commands (`TscSize`, `TscText`, `TscBarcode`, ...) instead of raw strings.
- Send it to a network printer with `FluttyTscPrinter.sendTscCommands`.
- Check that a printer is reachable with `FluttyTscPrinter.testConnection`.

## Supported platforms

Pure Dart implementation on top of `dart:io` sockets: it works on every
platform `dart:io` supports (Android, Windows, Linux, macOS, iOS).

## Installation

```yaml
dependencies:
  flutty_tsc_printer: ^0.1.0
```

## Usage

```dart
import 'package:flutty_tsc_printer/flutty_tsc_printer.dart';

// Print a label
final response = await FluttyTscPrinter.sendTscCommands(
  FluttyTscPrintRequest(
    ipAddress: '192.168.1.100',
    port: 9100,
    commands: [
      TscSize(width: 76, height: 25),
      TscGap(distance: 4, offset: 12),
      TscDirection(direction: 1),
      TscCls(),
      TscText(x: 10, y: 10, font: '3', content: 'Hello World'),
      TscBarcode(
        x: 10,
        y: 40,
        height: 50,
        narrow: 2,
        wide: 4,
        content: '123456789',
      ),
      TscPrint(quantity: 1),
    ],
  ),
);

switch (response) {
  case PrintSuccessResponse(:final message):
    debugPrint('Printed: $message');
  case PrintBadParamResponse(:final message):
    debugPrint('Invalid request: $message');
  case PrintErrorResponse(:final message):
    debugPrint('Printer error: $message');
}
```

### Testing the connection

```dart
final reachable = await FluttyTscPrinter.testConnection(
  FluttyTscTestConnectionRequest(ipAddress: '192.168.1.100', port: 9100),
);
```

`testConnection` throws an `Exception` carrying the socket error message when
the printer cannot be reached.

## Available commands

`TscSize`, `TscGap`, `TscAutoDetect`, `TscGapDetect`, `TscCodepage`,
`TscDirection`, `TscCls`, `TscCut`, `TscText`, `TscBarcode`, `TscPrint`,
and `TscRaw` for any TSPL command not covered above.

The command list must not be empty and should end with a `TscPrint` command,
otherwise `sendTscCommands` returns a `PrintBadParamResponse`.

## Android permissions

Network printing requires the internet permission in your app's
`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Example

See `packages/flutty_tsc_printer/example` for a small demo app that sends a test
label to a printer.

## Documentation

TSPL reference:
<https://www.icintracom.biz/redazione/libretti/libretto7028-04-1.pdf>

## API Documentation

See the [API docs](https://pub.dev/documentation/flutty_tsc_printer/latest/) for full documentation.
