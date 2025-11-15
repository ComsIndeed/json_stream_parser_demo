import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/pages/api_demo/api_doc_view.dart';
import 'package:json_stream_parser_demo/pages/api_demo/stream_notifier.dart';
import 'package:json_stream_parser_demo/pages/api_demo/tags_list_view.dart';

class ApiView extends StatelessWidget {
  const ApiView({super.key, required StreamNotifier streamNotifier})
    : _streamNotifier = streamNotifier;

  final StreamNotifier _streamNotifier;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _streamNotifier,
      builder: (context, _) {
        final parser = _streamNotifier.parser;
        final streamKey = _streamNotifier.streamKey;

        return Column(
          children: [
            ApiDocView(
              leading: const Icon(Icons.title),
              title: 'parser.getStringProperty("name").stream.listen(...);',
              subtitle:
                  'Provides the "name" property from the JSON data as a stream, receiving the chunks as it arrives from the main stream.',
              stream: parser?.getStringProperty("name").stream,
              type: ApiDocOutputType.stream,
              streamKey: streamKey,
            ),
            ApiDocView(
              leading: const Icon(Icons.description),
              title:
                  'parser.getStringProperty("description").stream.listen(...);',
              subtitle:
                  'Provides the "description" property from the JSON data as a stream, receiving the chunks as it arrives from the main stream.',
              stream: parser?.getStringProperty("description").stream,
              type: ApiDocOutputType.stream,
              streamKey: streamKey,
            ),
            ApiDocView(
              leading: const Icon(Icons.description_outlined),
              title: 'await parser.getStringProperty("description").future;',
              subtitle:
                  'Provides the "description" property from the JSON data as a future, resolving once the entire property value has been received.',
              type: ApiDocOutputType.future,
              future: parser?.getStringProperty("description").future,
              streamKey: streamKey,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TagsListView(parser: parser, streamKey: streamKey),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ApiDocView(
                          leading: const Icon(Icons.code),
                          title:
                              'parser.getStringProperty("details.color").stream;',
                          streamKey: streamKey,
                          stream: parser
                              ?.getStringProperty("details.color")
                              .stream,
                          subtitle:
                              'Provides the "color" property nested within the "details" object as a stream.',
                          type: ApiDocOutputType.stream,
                        ),
                        ApiDocView(
                          leading: const Icon(Icons.code_off),
                          title:
                              'await parser.getStringProperty("details.weight").future;',
                          streamKey: streamKey,
                          future: parser
                              ?.getStringProperty("details.weight")
                              .future,
                          subtitle:
                              'Provides the "weight" property nested within the "details" object as a future.',
                          type: ApiDocOutputType.future,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
