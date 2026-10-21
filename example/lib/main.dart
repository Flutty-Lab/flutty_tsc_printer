import 'package:flutter/material.dart';
import 'package:flutty_tsc_printer/flutty_tsc_printer.dart';

void main() {
  runApp(const FluttyTscPrinterExample());
}

class FluttyTscPrinterExample extends StatelessWidget {
  const FluttyTscPrinterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutty TSC Printer Example',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ipController = TextEditingController(
    text: '192.168.1.100',
  );
  final TextEditingController _portController = TextEditingController(
    text: '9100',
  );
  final TextEditingController _textController = TextEditingController(
    text: 'Hello World',
  );

  String _status = 'Idle';
  bool _busy = false;

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _textController.dispose();
    super.dispose();
  }

  int get _port => int.tryParse(_portController.text.trim()) ?? 9100;

  Future<void> _run(Future<String> Function() action) async {
    setState(() {
      _busy = true;
      _status = 'Running…';
    });
    String result;
    try {
      result = await action();
    } on Exception catch (e) {
      result = 'Failed: $e';
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = result;
    });
  }

  Future<void> _testConnection() {
    return _run(() async {
      final reachable = await FluttyTscPrinter.testConnection(
        FluttyTscTestConnectionRequest(
          ipAddress: _ipController.text.trim(),
          port: _port,
        ),
      );
      return reachable ? 'Printer reachable' : 'Printer unreachable';
    });
  }

  Future<void> _printLabel() {
    return _run(() async {
      final response = await FluttyTscPrinter.sendTscCommands(
        FluttyTscPrintRequest(
          ipAddress: _ipController.text.trim(),
          port: _port,
          commands: [
            TscSize(width: 76, height: 25),
            TscGap(distance: 4, offset: 12),
            TscDirection(direction: 1),
            TscCls(),
            TscText(x: 10, y: 10, font: '3', content: _textController.text),
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

      return switch (response) {
        PrintSuccessResponse(:final message) => 'Printed: ${message ?? 'ok'}',
        PrintBadParamResponse(:final message) => 'Invalid request: $message',
        PrintErrorResponse(:final message) =>
          'Printer error: ${message ?? 'unknown'}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutty_tsc_printer demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(labelText: 'Printer IP address'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Port'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(labelText: 'Label text'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _testConnection,
            child: const Text('Test connection'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _printLabel,
            child: const Text('Print label'),
          ),
          const SizedBox(height: 24),
          Text(_status),
        ],
      ),
    );
  }
}
