## 0.1.0

* Replace the vendor TSC SDKs (`CommSDK.dll` on Windows, `tscsdk.jar` on
  Android) with a pure-Dart TCP implementation built on `dart:io` sockets.
  The public API (`FluttyTscPrinter.sendTscCommands` and `testConnection`) is
  unchanged, and the package now works on every `dart:io` platform.
* The package is no longer a Flutter plugin: the native Android/Windows code
  and the method-channel scaffolding are removed, along with the
  `plugin_platform_interface` dependency.
* Remove `toMap()` from the request models (it only existed to serialize calls
  through the method channel).

## 0.0.4

* Fix: rename `flutter_tsc_bundled_libraries` to `flutty_tsc_printer_bundled_libraries` in the Windows CMake config.
* Fix: correct `CommSDK.dll` loading on Windows.

## 0.0.3

* Fix: remove a redundant mutex in the Windows implementation.

## 0.0.2

* Rename `printLabel` to `sendTscCommands`.
* Add the `CODEPAGE` command and other missing TSPL commands.
* Fix: treat a `nullptr` answer from `pWriteAndWaitForResponse` as a success (the printer sends no response).

## 0.0.1

* Initial release: send TSPL commands to a TSC label printer over TCP/IP.
* `FluttyTscPrinter.sendTscCommands` and `FluttyTscPrinter.testConnection`.
* Android and Windows support.
