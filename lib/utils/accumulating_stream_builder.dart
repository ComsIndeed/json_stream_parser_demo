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
  String _accumulated = '';
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen(
      (chunk) {
        setState(() {
          _accumulated += chunk;
        });
      },
      onError: (error) {
        // Handle error if needed
      },
      onDone: () {
        // Stream is done
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AsyncSnapshot<String>.withData(
      ConnectionState.active,
      _accumulated,
    );
    return widget.builder(context, snapshot);
  }
}
