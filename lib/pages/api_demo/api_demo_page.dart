import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_stream_parser_demo/pages/api_demo/api_view.dart';
import 'package:json_stream_parser_demo/pages/api_demo/stream_notifier.dart';
import '../../utils/stream_text_in_chunks.dart';
import '../../utils/accumulating_stream_builder.dart';

class ApiDemoPage extends StatefulWidget {
  const ApiDemoPage({super.key});

  @override
  State<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends State<ApiDemoPage> {
  final StreamNotifier _streamNotifier = StreamNotifier();
  int _chunkSize = 1;
  int _intervalMs = 50;
  bool _isSliderVisible = true;

  @override
  void dispose() {
    _streamNotifier.dispose();
    super.dispose();
  }

  String get exampleApiResponse => jsonEncode({
    "name": "Sample Item",
    "description":
        "This is a very long description that could potentially span multiple lines and contain a lot of information about the item, including its features, benefits, and usage.", // long description value
    "tags": [
      // list of strings
      "sample tag 1 with some extra info",
      "sample tag 2 with more details",
      "sample tag 3 that is a bit longer",
    ],
    "details": {
      // nested map
      "color": "red",
      "size": "large",
      "weight": "1.5kg",
      "material": "plastic",
    },
    "status": "active", // ending string key-value pair
  });

  void _runStream() {
    // Create stream controller to manually control when stream starts
    final controller = StreamController<String>.broadcast();

    // Update the notifier with the new stream
    _streamNotifier.updateStream(controller.stream);

    // Start streaming after a small delay to ensure widgets are subscribed
    Future.delayed(Duration(milliseconds: 50), () {
      streamTextInChunks(
        text: exampleApiResponse,
        chunkSize: _chunkSize,
        interval: Duration(milliseconds: _intervalMs),
      ).listen(
        (chunk) => controller.add(chunk),
        onDone: () => controller.close(),
        onError: (error) => controller.addError(error),
      );
    });
  }

  Widget _buildFormattedJson(BuildContext context, String text) {
    // Build a custom text widget with monospace font, character wrapping, and space visualization
    return Text.rich(
      TextSpan(
        children: text.split('').map((char) {
          if (char == ' ') {
            // Visualize spaces as low-contrast circles
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(38),
                ),
              ),
            );
          } else {
            return TextSpan(
              text: char,
              style: GoogleFonts.robotoMono(fontSize: 16),
            );
          }
        }).toList(),
      ),
      softWrap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    return Center(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: []),
          SizedBox(height: 32),
          Row(
            children: [
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "JsonStreamParser API Demo",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: sizes.width * 0.25,
                    height: sizes.height * 0.7,
                    child: Card(
                      surfaceTintColor: Colors.white,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSliderVisible = !_isSliderVisible;
                                });
                              },
                              child: Text(
                                "LIVE JSON Stream:",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            _isSliderVisible
                                ? Column(
                                    children: [
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
                                              min: 10,
                                              max: 1000,
                                              divisions: 99,
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
                                    ],
                                  )
                                : Container(),
                            SizedBox(height: 16),
                            Expanded(
                              child: ListenableBuilder(
                                listenable: _streamNotifier,
                                builder: (context, _) {
                                  final stream = _streamNotifier.currentStream;
                                  final streamKey = _streamNotifier.streamKey;

                                  return stream != null
                                      ? SingleChildScrollView(
                                          child: AccumulatingStreamBuilder(
                                            key: ValueKey(streamKey),
                                            stream: stream,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    16.0,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: _buildFormattedJson(
                                                      context,
                                                      snapshot.data ?? "",
                                                    ),
                                                  ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    'Error: ${snapshot.error}',
                                                  ),
                                                );
                                              } else {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            'Press "Run Stream" to start',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        );
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            MarkdownBody(
                              data:
                                  r'```final parser = JsonStreamParser(stream);```',
                              styleSheet: MarkdownStyleSheet(
                                code: GoogleFonts.robotoMono(
                                  fontSize: 14,
                                  backgroundColor: Colors.green.withAlpha(30),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            FilledButton(
                              onPressed: _runStream,
                              child: Text("Run Streams"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: sizes.height * 0.8,
                  child: ApiView(streamNotifier: _streamNotifier),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
