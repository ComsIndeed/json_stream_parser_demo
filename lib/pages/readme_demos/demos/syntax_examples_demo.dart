import 'dart:async';
import 'package:flutter/material.dart';

import 'package:json_stream_parser_demo/pages/readme_demos/demo_card.dart';
import 'package:json_stream_parser_demo/utils/json_stream_extensions.dart';

class SyntaxExamplesDemo extends StatelessWidget {
  final bool startImmediately;
  const SyntaxExamplesDemo({super.key, this.startImmediately = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DemoCard(
          title: '4a. Direct Path Access',
          startImmediately: startImmediately,
          json: '{"user": {"name": "Alice", "profile": {"age": 30}}}',
          code: 'parser.str("user.name").stream.listen(...)',
          builder: (context, parser) =>
              _SimpleStreamText(parser.str('user.name').stream),
        ),
        DemoCard(
          title: '4b. Chaining Access',
          startImmediately: startImmediately,
          json: '{"user": {"profile": {"age": 30}}}',
          code: 'await parser.map("user").map("profile").number("age").future',
          builder: (context, parser) => _SimpleFutureText(
              parser.map('user').map('profile').number('age').future),
        ),
        DemoCard(
          title: '4c. List Index Access',
          startImmediately: startImmediately,
          json: '{"items": [{"name": "Item A"}, {"name": "Item B"}]}',
          code: 'parser.str("items[1].name").stream.listen(...)',
          builder: (context, parser) =>
              _SimpleStreamText(parser.str('items[1].name').stream),
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

class _SimpleFutureText extends StatelessWidget {
  final Future<dynamic> future;
  const _SimpleFutureText(this.future);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return Text(
          snapshot.hasData ? snapshot.data.toString() : "Waiting...",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
