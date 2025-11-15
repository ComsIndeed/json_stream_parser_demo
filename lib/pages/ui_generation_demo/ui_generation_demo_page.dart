import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_stream_parser_demo/pages/ui_generation_demo/widget_stream_handler.dart';
import 'package:json_stream_parser_demo/utils/accumulating_stream_builder.dart';
import 'package:provider/provider.dart';

class UiGenerationDemoPage extends StatefulWidget {
  const UiGenerationDemoPage({super.key});

  @override
  State<UiGenerationDemoPage> createState() => _UiGenerationDemoPageState();
}

class _UiGenerationDemoPageState extends State<UiGenerationDemoPage> {
  int _chunkSize = 5;
  int _intervalMs = 50;
  bool _isSliderVisible = true;

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
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(38),
                ),
              ),
            );
          } else {
            return TextSpan(
              text: char,
              style: GoogleFonts.robotoMono(fontSize: 14),
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
    return ChangeNotifierProvider(
      create: (context) => WidgetStreamHandler(),
      child: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            final handler = context.read<WidgetStreamHandler>();
            handler.runDemo(_chunkSize, _intervalMs);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "UI Generation Demo",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                _isSliderVisible
                                    ? Column(
                                        children: [
                                          const SizedBox(height: 16),
                                          // Chunk Size Control
                                          Row(
                                            children: [
                                              const Text("Chunk Size:"),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Slider(
                                                  value: _chunkSize.toDouble(),
                                                  min: 1,
                                                  max: 50,
                                                  divisions: 49,
                                                  label: _chunkSize.toString(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _chunkSize =
                                                          value.toInt();
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(_chunkSize.toString()),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Interval Control
                                          Row(
                                            children: [
                                              const Text("Interval (ms):"),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Slider(
                                                  value: _intervalMs.toDouble(),
                                                  min: 10,
                                                  max: 1000,
                                                  divisions: 99,
                                                  label: _intervalMs.toString(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _intervalMs =
                                                          value.toInt();
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(_intervalMs.toString()),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Container(),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Consumer<WidgetStreamHandler>(
                                    builder: (context, handler, _) {
                                      final stream = handler.currentStream;
                                      final streamKey = handler.streamKey;

                                      return stream != null
                                          ? SingleChildScrollView(
                                              child: AccumulatingStreamBuilder(
                                                key: ValueKey(streamKey),
                                                stream: stream,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        16.0,
                                                      ),
                                                      child:
                                                          SingleChildScrollView(
                                                        child:
                                                            _buildFormattedJson(
                                                          context,
                                                          snapshot.data ?? "",
                                                        ),
                                                      ),
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                      child: Text(
                                                        'Error: ${snapshot.error}',
                                                      ),
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                },
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                'Press "Run Demo" to start',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                MarkdownBody(
                                  data:
                                      r'```final parser = JsonStreamParser(stream);```',
                                  styleSheet: MarkdownStyleSheet(
                                    code: GoogleFonts.robotoMono(
                                      fontSize: 14,
                                      backgroundColor:
                                          Colors.green.withAlpha(30),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Consumer<WidgetStreamHandler>(
                                  builder: (context, handler, _) {
                                    return FilledButton(
                                      onPressed: () {
                                        handler.runDemo(
                                            _chunkSize, _intervalMs);
                                      },
                                      child: const Text.rich(
                                        TextSpan(
                                          text: "Run Demo",
                                          children: [
                                            TextSpan(
                                              text: " (Spacebar)",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
                      child: Consumer<WidgetStreamHandler>(
                        builder: (context, handler, _) {
                          return Card(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(64),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child: handler.rootWidget != null
                                  ? AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: Container(
                                        key: ValueKey(handler.streamKey),
                                        child: handler.rootWidget!.build(
                                          context,
                                          isComplete: !handler.isBuilding,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.web,
                                            size: 64,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withAlpha(100),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Generated UI will appear here',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withAlpha(150),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
