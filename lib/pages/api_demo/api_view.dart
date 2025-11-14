import 'package:flutter/material.dart';
import 'package:json_stream_parser/classes/json_stream_parser.dart';
import 'package:json_stream_parser_demo/pages/api_demo/api_doc_view.dart';

class ApiView extends StatelessWidget {
  const ApiView({
    super.key,
    required JsonStreamParser? parser,
    required int streamKey,
  }) : _parser = parser,
       _streamKey = streamKey;

  final JsonStreamParser? _parser;
  final int _streamKey;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ApiDocView(
          leading: const Icon(Icons.circle),
          title: '.getStringProperty("name").stream',
          subtitle:
              'This line provides the "name" property from the JSON data as a stream, receiving the chunks as it arrives from the main stream.',
          stream: _parser?.getStringProperty("name").stream,
          type: ApiDocOutputType.stream,
          streamKey: _streamKey,
        ),
        ApiDocView(
          leading: const Icon(Icons.description),
          title: '.getStringProperty("description").stream',
          subtitle:
              'This line provides the "description" property from the JSON data as a stream, receiving the chunks as it arrives from the main stream.',
          stream: _parser?.getStringProperty("description").stream,
          type: ApiDocOutputType.stream,
          streamKey: _streamKey,
        ),
      ],
    );
  }
}
