import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_stream_parser/classes/json_stream_parser.dart';
import '../../utils/stream_text_in_chunks.dart';
import '../../utils/accumulating_stream_builder.dart';

class ApiDemoPage extends StatefulWidget {
  const ApiDemoPage({super.key});

  @override
  State<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends State<ApiDemoPage> {
  late Stream<String>? _currentStream;
  JsonStreamParser? _parser;
  int _chunkSize = 50;
  int _intervalMs = 500;
  int _streamKey = 0; // Key to force rebuild of StreamBuilder

  @override
  void initState() {
    super.initState();
    _currentStream = null;
  }

  String get exampleApiResponse => jsonEncode({
    'status': 'success',
    'data': {
      'id': 123,
      'name': 'Sample Item',
      'description': 'This is a sample item from the API response.',
      'attributes': {'color': 'red', 'size': 'large', 'weight': '1.5kg'},
    },
    'message': 'Item retrieved successfully.',
  });

  void _runStream() {
    setState(() {
      // Increment key to force rebuild and create a new stream instance
      _streamKey++;
      _currentStream = streamTextInChunks(
        text: exampleApiResponse,
        chunkSize: _chunkSize,
        interval: Duration(milliseconds: _intervalMs),
      ).asBroadcastStream();
      if (_currentStream != null) _parser = JsonStreamParser(_currentStream!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    return Center(
      child: Column(
        children: [
          Text(
            "JsonStreamParser API Demo",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 32),
          Row(
            children: [
              SizedBox(
                width: sizes.width * 0.25,
                height: sizes.height * 0.8,
                child: Card(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    // JSON STREAM VIEW
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            Text(
                              "LIVE JSON Stream:",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(width: 16),
                            FilledButton(
                              onPressed: _runStream,
                              child: Text("Run Stream"),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Chunk Size Control
                        Row(
                          children: [
                            Text("Chunk Size:"),
                            SizedBox(width: 8),
                            Expanded(
                              child: Slider(
                                value: _chunkSize.toDouble(),
                                min: 1,
                                max: 50,
                                divisions: 49,
                                label: _chunkSize.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _chunkSize = value.toInt();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(_chunkSize.toString()),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Interval Control
                        Row(
                          children: [
                            Text("Interval (ms):"),
                            SizedBox(width: 8),
                            Expanded(
                              child: Slider(
                                value: _intervalMs.toDouble(),
                                min: 100,
                                max: 2000,
                                divisions: 19,
                                label: _intervalMs.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _intervalMs = value.toInt();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(_intervalMs.toString()),
                          ],
                        ),
                        SizedBox(height: 16),
                        _currentStream != null
                            ? AccumulatingStreamBuilder(
                                key: ValueKey(
                                  _streamKey,
                                ), // Force rebuild on new stream
                                stream: _currentStream!,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: MarkdownBody(
                                        data: "`\n${snapshot.data}\n`",
                                        styleSheet: MarkdownStyleSheet(
                                          code: GoogleFonts.robotoMono()
                                              .copyWith(fontSize: 24),
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              )
                            : Center(
                                child: Text(
                                  'Press "Run Stream" to start',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: sizes.height * 0.8,
                  child: Card(
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    // API RESPONSE VIEW
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                leading: Icon(Icons.circle),
                                title: Text(
                                  '.getStringProperty("status").stream',
                                  style: GoogleFonts.robotoMono(),
                                ),
                                subtitle: _parser != null
                                    ? AccumulatingStreamBuilder(
                                        key: ValueKey('status_$_streamKey'),
                                        stream: _parser!
                                            .getStringProperty("status")
                                            .stream,
                                        builder: (_, snapshot) => Text(
                                          snapshot.data ?? "",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      )
                                    : Text(""),
                              ),
                              ListTile(
                                leading: Icon(Icons.circle),
                                title: Text(
                                  '.getStringProperty("message").stream',
                                  style: GoogleFonts.robotoMono(),
                                ),
                                subtitle: _parser != null
                                    ? AccumulatingStreamBuilder(
                                        key: ValueKey('message_$_streamKey'),
                                        stream: _parser!
                                            .getStringProperty("message")
                                            .stream,
                                        builder: (_, snapshot) => Text(
                                          snapshot.data ?? "",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      )
                                    : Text(""),
                              ),
                              ListTile(
                                leading: Icon(Icons.data_object),
                                title: Text(
                                  '.getStringProperty("data.name").stream',
                                  style: GoogleFonts.robotoMono(fontSize: 12),
                                ),
                                subtitle: _parser != null
                                    ? AccumulatingStreamBuilder(
                                        key: ValueKey('data_name_$_streamKey'),
                                        stream: _parser!
                                            .getStringProperty("data.name")
                                            .stream,
                                        builder: (_, snapshot) => Text(
                                          snapshot.data ?? "",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      )
                                    : Text(""),
                              ),
                              ListTile(
                                leading: Icon(Icons.description),
                                title: Text(
                                  '.getStringProperty("data.description").stream',
                                  style: GoogleFonts.robotoMono(fontSize: 12),
                                ),
                                subtitle: _parser != null
                                    ? AccumulatingStreamBuilder(
                                        key: ValueKey(
                                          'data_description_$_streamKey',
                                        ),
                                        stream: _parser!
                                            .getStringProperty(
                                              "data.description",
                                            )
                                            .stream,
                                        builder: (_, snapshot) => Text(
                                          snapshot.data ?? "",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      )
                                    : Text(""),
                              ),
                              ListTile(
                                leading: Icon(Icons.palette),
                                title: Text(
                                  '.getStringProperty("data.attributes.color").stream',
                                  style: GoogleFonts.robotoMono(fontSize: 12),
                                ),
                                subtitle: _parser != null
                                    ? AccumulatingStreamBuilder(
                                        key: ValueKey('color_$_streamKey'),
                                        stream: _parser!
                                            .getStringProperty(
                                              "data.attributes.color",
                                            )
                                            .stream,
                                        builder: (_, snapshot) => Text(
                                          snapshot.data ?? "",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      )
                                    : Text(""),
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_size_select_large),
                                title: Text(
                                  '.getStringProperty("data.attributes.size").stream',
                                  style: GoogleFonts.robotoMono(fontSize: 12),
                                ),
                                subtitle: _parser != null
                                    ? AccumulatingStreamBuilder(
                                        key: ValueKey('size_$_streamKey'),
                                        stream: _parser!
                                            .getStringProperty(
                                              "data.attributes.size",
                                            )
                                            .stream,
                                        builder: (_, snapshot) => Text(
                                          snapshot.data ?? "",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      )
                                    : Text(""),
                              ),
                              ListTile(
                                leading: Icon(Icons.scale),
                                title: Text(
                                  '.getStringProperty("data.attributes.weight").stream',
                                  style: GoogleFonts.robotoMono(fontSize: 12),
                                ),
                                subtitle: _parser != null
                                    ? AccumulatingStreamBuilder(
                                        key: ValueKey('weight_$_streamKey'),
                                        stream: _parser!
                                            .getStringProperty(
                                              "data.attributes.weight",
                                            )
                                            .stream,
                                        builder: (_, snapshot) => Text(
                                          snapshot.data ?? "",
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      )
                                    : Text(""),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: ListView(children: [])),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
