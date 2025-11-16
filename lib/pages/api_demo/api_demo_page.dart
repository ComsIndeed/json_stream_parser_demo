import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_stream_parser_demo/pages/api_demo/api_view.dart';
import 'package:json_stream_parser_demo/pages/api_demo/stream_notifier.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
  StreamController<String>? _currentController;

  @override
  void dispose() {
    _currentController?.close();
    _streamNotifier.dispose();
    super.dispose();
  }

  String get exampleApiResponse => jsonEncode({
        "name": "Sample Item",
        "description":
            "This is a very long description that could potentially span multiple lines and contain a lot of information about the item, including its features, benefits, and usage.",
        "tags": [
          "sample tag 1 with some extra info",
          "sample tag 2 with more details",
          "sample tag 3 that is a bit longer",
        ],
        "details": {
          "color": "red",
          "size": "large",
          "weight": "1.5kg",
          "material": "plastic",
        },
        "status": "active",
      });

  void _runStream() {
    // Cancel and close any existing controller
    _currentController?.close();

    final controller = StreamController<String>.broadcast();
    _currentController = controller;
    _streamNotifier.updateStream(controller.stream);

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
    return Text.rich(
      TextSpan(
        children: text.split('').map((char) {
          if (char == ' ') {
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

  Widget _buildLeftPanel(BuildContext context, Size sizes, bool isMobile) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
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
                                  padding: const EdgeInsets.all(16.0),
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
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            'Press "Run Stream" to start',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                },
              ),
            ),
            SizedBox(height: 16),
            MarkdownBody(
              data: r'```final parser = JsonStreamParser(stream);```',
              styleSheet: MarkdownStyleSheet(
                code: GoogleFonts.robotoMono(
                  fontSize: isMobile ? 11 : 14,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(height: 16),
            FilledButton(
              onPressed: _runStream,
              child: Text.rich(
                TextSpan(
                  text: "Run Streams",
                  children: [
                    if (!isMobile)
                      TextSpan(
                        text: " (Spacebar)",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withAlpha(179),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = MediaQuery.sizeOf(context);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          _runStream();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Center(
        child: Column(
          children: [
            if (!isDesktop)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      MarkdownBody(
                          data:
                              '# **LLM JSON Stream** API Demo\n(Please avoid changing the screen size for now)'),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: isDesktop ? 400 : sizes.height * 0.8,
                        child: _buildLeftPanel(context, sizes, isMobile),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: isDesktop ? 400 : 1500,
                        child: ApiView(
                            streamNotifier: _streamNotifier,
                            isDesktop: isDesktop),
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              )
            else
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
                        child: _buildLeftPanel(context, sizes, isMobile),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SizedBox(
                      height: sizes.height * 0.8,
                      child: ApiView(
                          streamNotifier: _streamNotifier,
                          isDesktop: isDesktop),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
