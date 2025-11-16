import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:llm_json_stream/classes/json_stream_parser.dart';
import 'package:llm_json_stream/classes/property_stream.dart';

class TagsListView extends StatefulWidget {
  const TagsListView({
    super.key,
    required this.parser,
    required this.streamKey,
  });

  final JsonStreamParser? parser;
  final int streamKey;

  @override
  State<TagsListView> createState() => _TagsListViewState();
}

class _TagsListViewState extends State<TagsListView> {
  final List<String> _tags = [];
  final List<StreamSubscription> _subscriptions = [];
  int _currentStreamKey = 0;

  @override
  void initState() {
    super.initState();
    _currentStreamKey = widget.streamKey;
    _listenToTags();
  }

  @override
  void didUpdateWidget(TagsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamKey != widget.streamKey) {
      _currentStreamKey = widget.streamKey;
      _cancelSubscriptions();
      setState(() {
        _tags.clear();
      });
      _listenToTags();
    }
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void _listenToTags() {
    if (widget.parser == null) return;

    final capturedStreamKey = _currentStreamKey;

    widget.parser!.getListProperty<String>(
      'tags',
      onElement: (propertyStream, index) async {
        final stringStream = propertyStream as StringPropertyStream;
        final subscription = stringStream.stream.listen((chunk) {
          if (capturedStreamKey == _currentStreamKey) {
            setState(() {
              if (index >= _tags.length) {
                _tags.add(chunk);
              } else {
                _tags[index] = (_tags[index]) + chunk;
              }
            });
          }
        });
        _subscriptions.add(subscription);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(10.0),
        //   child: Icon(Icons.list_alt),
        // ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'parser.getListProperty("tags", onElement: ...);',
                  style: GoogleFonts.robotoMono().copyWith(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(128),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '[${_tags.length}] Listens to the "tags" array and builds a list as items stream in.\n`onElement` runs immediately on the first token of a value found before it\'s even complete and parseable.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                _tags.isEmpty
                    ? const Center(child: Text('Press "Run Stream" to start'))
                    : Column(
                        children: _tags.map((tag) {
                          return Card(
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                                width: 1,
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                tag,
                                style: GoogleFonts.robotoMono(),
                              ),
                            ),
                          ).animate().scaleXY(
                                begin: 0.2,
                                curve: Curves.easeOutBack,
                              );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
