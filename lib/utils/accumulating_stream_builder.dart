import 'package:flutter/material.dart';
import 'dart:async';

class AccumulatingStreamBuilder extends StatefulWidget {
  const AccumulatingStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
  });

  final Stream<String> stream;
  final Widget Function(BuildContext context, AsyncSnapshot<String> snapshot)
  builder;

  @override
  State<AccumulatingStreamBuilder> createState() =>
      _AccumulatingStreamBuilderState();
}

class _AccumulatingStreamBuilderState extends State<AccumulatingStreamBuilder> {
  late Stream<String> accumulatedStream;
  late StreamController<String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<String>();
    String accumulated = '';

    widget.stream.listen(
      (chunk) {
        accumulated += chunk;
        _controller.add(accumulated);
      },
      onError: (error) => _controller.addError(error),
      onDone: () => _controller.close(),
    );

    accumulatedStream = _controller.stream;
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: accumulatedStream, builder: widget.builder);
  }
}
