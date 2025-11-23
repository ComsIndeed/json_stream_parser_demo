import 'dart:async';
import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demo_card.dart';

class CompletionDemo extends StatelessWidget {
  final bool startImmediately;
  const CompletionDemo({super.key, this.startImmediately = false});

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '7. Completion Signals',
      json: '{"data": "Some content...", "more": "More content..."}',
      code: '''
parser.onComplete(() {
  print('All JSON received');
  hideLoadingSpinner();
});
''',
      startImmediately: startImmediately,
      chunkSize: 2,
      interval: const Duration(milliseconds: 50),
      builder: (context, parser) {
        return _CompletionDisplay(parser: parser);
      },
    );
  }
}

class _CompletionDisplay extends StatefulWidget {
  final dynamic parser;
  const _CompletionDisplay({required this.parser});

  @override
  State<_CompletionDisplay> createState() => _CompletionDisplayState();
}

class _CompletionDisplayState extends State<_CompletionDisplay> {
  bool _isComplete = false;
  double _progress = 0.0;
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Drive the parser
    _subscription = widget.parser.str('data').stream.listen((_) {
      if (mounted && !_isComplete) {
        setState(() {
          _progress += 0.05;
          if (_progress > 0.9) _progress = 0.9;
        });
      }
    });

    // In a real scenario with onComplete, we'd just register the callback.
    // Here we simulate it by waiting for the last property or a timeout
    widget.parser.str('more').future.then((_) {
      // Give it a slight delay to look like "onComplete" firing after everything
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isComplete = true;
            _progress = 1.0;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          color: _isComplete ? Colors.green : null,
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 16),
        Text(
          _isComplete ? "Completed!" : "Streaming...",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isComplete ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
