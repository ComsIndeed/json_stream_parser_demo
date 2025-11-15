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
  bool _hasError = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(AccumulatingStreamBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _subscription?.cancel();
      _accumulated = '';
      _hasError = false;
      _error = null;
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.stream.listen(
      (chunk) {
        if (mounted) {
          setState(() {
            _accumulated += chunk;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _error = error;
          });
        }
      },
      onDone: () {
        // Stream is done
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncSnapshot<String> snapshot;
    if (_hasError) {
      snapshot = AsyncSnapshot<String>.withError(
        ConnectionState.active,
        _error!,
      );
    } else {
      snapshot = AsyncSnapshot<String>.withData(
        ConnectionState.active,
        _accumulated,
      );
    }
    return widget.builder(context, snapshot);
  }
}
