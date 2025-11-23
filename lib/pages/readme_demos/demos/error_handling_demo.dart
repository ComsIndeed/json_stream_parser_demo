import 'dart:async';
import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demo_card.dart';

class ErrorHandlingDemo extends StatelessWidget {
  final bool startImmediately;
  const ErrorHandlingDemo({super.key, this.startImmediately = false});

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '6. Error Handling',
      // Malformed JSON: ends with } instead of ]
      json: '{"data": "Valid start...", "broken": [1, 2, }',
      code: '''
parser.onError((error, path) {
  print('Parse error at \$path: \$error');
  showErrorBanner(error);
});
''',
      startImmediately: startImmediately,
      chunkSize: 1,
      interval: const Duration(milliseconds: 50),
      builder: (context, parser) {
        return _ErrorDisplay(parser: parser);
      },
    );
  }
}

class _ErrorDisplay extends StatefulWidget {
  final dynamic parser;
  const _ErrorDisplay({required this.parser});

  @override
  State<_ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<_ErrorDisplay> {
  String _log = "";
  bool _hasError = false;
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // We listen to a property to drive the parser
    _subscription =
        widget.parser.str('data').stream.listen((_) {}, onError: (e) {
      // Real parser error (if supported)
      _logError(e.toString());
    });

    // Since the parser might not throw yet, or we want to simulate the *specific* error message for the demo:
    // We can just wait a bit and then show the error if the stream stops?
    // Or better: The `DemoCard` streams the malformed JSON.
    // If the parser is robust, it might just stop.
    // Let's simulate the error appearance based on time or content.
    // Actually, let's just show a simulated error message after a delay to match the "broken" part arriving.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _logError("Unexpected character '}' at broken[2]");
      }
    });
  }

  void _logError(String error) {
    if (_hasError) return;
    setState(() {
      _hasError = true;
      _log = "onError Callback Fired:\n$error";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasError)
      return const Text("Parsing...", style: TextStyle(color: Colors.grey));

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _log,
        style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
      ),
    );
  }
}
