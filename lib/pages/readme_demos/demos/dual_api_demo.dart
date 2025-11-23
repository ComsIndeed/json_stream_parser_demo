import 'dart:async';
import 'package:flutter/material.dart';
import 'package:llm_json_stream/json_stream_parser.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demo_card.dart';
import 'package:json_stream_parser_demo/utils/json_stream_extensions.dart';

class DualApiDemo extends StatelessWidget {
  final bool startImmediately;
  const DualApiDemo({super.key, this.startImmediately = false});

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '3. Dual API (Future vs Stream)',
      json:
          '{"id": 12345, "description": "This is a long description that is streaming..."}',
      code: '''
// 1. Use .future for atomic values
// Completes as soon as "12345" is parsed
final id = await parser.number("id").future;

// 2. Use .stream for long text
// Updates UI chunk-by-chunk
parser.str("description").stream.listen((chunk) {
  descText += chunk;
});
''',
      startImmediately: startImmediately,
      chunkSize: 2,
      interval: const Duration(milliseconds: 80),
      builder: (context, parser) {
        return _DualApiContent(parser: parser);
      },
    );
  }
}

class _DualApiContent extends StatefulWidget {
  final JsonStreamParser parser;
  const _DualApiContent({required this.parser});

  @override
  State<_DualApiContent> createState() => _DualApiContentState();
}

class _DualApiContentState extends State<_DualApiContent> {
  String _idValue = "Waiting...";
  String _descValue = "";
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 1. Future
    widget.parser.number('id').future.then((id) {
      if (mounted) {
        setState(() {
          _idValue = id.toString();
        });
      }
    });

    // 2. Stream
    _subscription = widget.parser.str('description').stream.listen((chunk) {
      if (mounted) {
        setState(() {
          _descValue += chunk;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('ID (via .future): ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_idValue,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const Text('Description (via .stream):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _descValue.isEmpty ? 'Waiting for stream...' : _descValue,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
