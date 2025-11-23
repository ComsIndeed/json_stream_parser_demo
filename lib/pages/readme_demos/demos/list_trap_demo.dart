import 'dart:async';
import 'package:flutter/material.dart';
import 'package:llm_json_stream/json_stream_parser.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demo_card.dart';
import 'package:json_stream_parser_demo/utils/json_stream_extensions.dart';

class ListTrapDemo extends StatelessWidget {
  final bool startImmediately;
  const ListTrapDemo({super.key, this.startImmediately = false});

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: '2. "Arm the Trap" List Handling',
      json:
          '{"items": [{"name": "Item 1", "desc": "Description 1"}, {"name": "Item 2", "desc": "Description 2"}]}',
      code: '''
// "Arm the trap"
parser.list("items", onElement: (element, index) {
  // Fires IMMEDIATELY when new item starts
  
  // Add card to UI instantly
  myList.add(MyCard(index));

  // Listen to fields as they arrive
  element.asMap.str("name").stream.listen((chunk) {
    updateCardName(index, chunk);
  });
});
''',
      startImmediately: startImmediately,
      chunkSize: 2,
      interval: const Duration(milliseconds: 100),
      builder: (context, parser) {
        return _ListTrapContent(parser: parser);
      },
    );
  }
}

class _ListTrapContent extends StatefulWidget {
  final JsonStreamParser parser;
  const _ListTrapContent({required this.parser});

  @override
  State<_ListTrapContent> createState() => _ListTrapContentState();
}

class _ListTrapContentState extends State<_ListTrapContent> {
  final List<Widget> _cards = [];
  final List<StreamSubscription> _subscriptions = [];

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // "Arm the trap"
    widget.parser.list('items', onElement: (elementStream, index) {
      _addCard(elementStream, index);
    });
  }

  void _addCard(PropertyStream elementStream, int index) {
    final nameController = ValueNotifier<String>("");
    final descController = ValueNotifier<String>("");

    if (mounted) {
      setState(() {
        _cards.add(
          Card(
            key: ValueKey(index),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item ${index + 1}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<String>(
                    valueListenable: nameController,
                    builder: (context, value, _) => Text(
                      value.isEmpty ? 'Loading name...' : value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<String>(
                    valueListenable: descController,
                    builder: (context, value, _) => Text(
                      value.isEmpty ? 'Loading description...' : value,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }

    if (elementStream is MapPropertyStream) {
      _subscriptions.add(elementStream.str('name').stream.listen((chunk) {
        nameController.value += chunk;
      }));
      _subscriptions.add(elementStream.str('desc').stream.listen((chunk) {
        descController.value += chunk;
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: _cards.length,
        itemBuilder: (context, index) => _cards[index],
      ),
    );
  }
}
