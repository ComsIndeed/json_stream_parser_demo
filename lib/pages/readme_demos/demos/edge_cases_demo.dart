import 'dart:async';
import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demo_card.dart';
import 'package:json_stream_parser_demo/utils/json_stream_extensions.dart';

class EdgeCasesDemo extends StatelessWidget {
  final bool startImmediately;
  const EdgeCasesDemo({super.key, this.startImmediately = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DemoCard(
          title: '5a. Edge Case: Special Characters',
          startImmediately: startImmediately,
          json: '{"text": "Line 1\\nLine 2\\tTabbed\\n\\"Quoted\\""}',
          code: 'parser.str("text").stream.listen(...)',
          chunkSize: 1,
          interval: const Duration(milliseconds: 30),
          builder: (context, parser) =>
              _SimpleStreamText(parser.str('text').stream),
        ),
        DemoCard(
          title: '5b. Edge Case: Multiline JSON',
          startImmediately: startImmediately,
          json: '''
{
  "user": {
    "name": "Bob",
    "bio": "Loves coding."
  }
}
''',
          code: 'parser.str("user.bio").stream.listen(...)',
          chunkSize: 1,
          interval: const Duration(milliseconds: 30),
          builder: (context, parser) =>
              _SimpleStreamText(parser.str('user.bio').stream),
        ),
      ],
    );
  }
}

class _SimpleStreamText extends StatefulWidget {
  final Stream<String> stream;
  const _SimpleStreamText(this.stream);
  @override
  State<_SimpleStreamText> createState() => _SimpleStreamTextState();
}

class _SimpleStreamTextState extends State<_SimpleStreamText> {
  String _text = "";
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen((chunk) {
      if (mounted) setState(() => _text += chunk);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Text(_text.isEmpty ? "Waiting..." : _text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}
