import 'dart:async';
import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demo_card.dart';
import 'package:json_stream_parser_demo/utils/json_stream_extensions.dart';

class StringStreamDemo extends StatelessWidget {
  final bool startImmediately;
  const StringStreamDemo({super.key, this.startImmediately = false});

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '1. Streaming String Property',
      json: '{"title": "My Great Blog Post", "content": "..."}',
      code: '''
// Subscribe to the 'title' property
final titleStream = parser.str("title");

// Listen to its .stream
titleStream.stream.listen((chunk) {
  // Updates token-by-token
  myTextWidget.text += chunk;
});
''',
      startImmediately: startImmediately,
      chunkSize: 1,
      interval: const Duration(milliseconds: 50),
      builder: (context, parser) {
        // Use the new extension method .str()
        final titleStream = parser.str('title');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Blog Post Title',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<String>(
              stream: titleStream.stream,
              builder: (context, snapshot) {
                // Accumulate chunks for display
                // Note: In a real app, you'd accumulate in a stateful widget or use a specialized widget
                // For this simple demo, we can use a custom accumulating widget or just let the stream builder rebuild
                // But StreamBuilder with a stream only gives the latest event.
                // We need to accumulate.
                return _AccumulatingText(stream: titleStream.stream);
              },
            ),
          ],
        );
      },
    );
  }
}

class _AccumulatingText extends StatefulWidget {
  final Stream<String> stream;
  const _AccumulatingText({required this.stream});

  @override
  State<_AccumulatingText> createState() => _AccumulatingTextState();
}

class _AccumulatingTextState extends State<_AccumulatingText> {
  String _text = "";
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen((chunk) {
      if (mounted) {
        setState(() {
          _text += chunk;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _text.isEmpty ? 'Waiting for stream...' : _text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
