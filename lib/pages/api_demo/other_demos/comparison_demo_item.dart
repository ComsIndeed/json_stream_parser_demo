import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_stream_parser_demo/utils/accumulating_stream_builder.dart';
import 'package:llm_json_stream/classes/json_stream_parser.dart';
import 'package:llm_json_stream/classes/property_stream.dart';
import 'package:json_stream_parser_demo/utils/stream_text_in_chunks.dart';

// Custom Main Demo Widget - Clone of _DemoItem with hardcoded values
// This widget can be customized independently for your main demo
class ComparisonDemoItem extends StatefulWidget {
  final Duration interval;
  final int chunkSize;
  final bool allowExpansion;
  final bool startImmediately;

  const ComparisonDemoItem({
    super.key,
    required this.interval,
    required this.chunkSize,
    required this.allowExpansion,
    required this.startImmediately,
  });

  @override
  State<ComparisonDemoItem> createState() => _ComparisonDemoItemState();
}

class _ComparisonDemoItemState extends State<ComparisonDemoItem> {
  StreamController<String>? _controller;
  JsonStreamParser? _parser;
  String _streamedJson = '';
  bool _isActive = false;
  StreamSubscription<String>? subscription;
  String currentAccumulatedJson = '';

  // Hardcoded values for this demo - customize these as needed!
  String get _title => 'Comparison Demo';
  // String get _code => 'final parser = JsonStreamParser(stream);\n'
  //     'final titleStream = parser.getStringProperty("title").stream;\n'
  //     'final authorStream = parser.getStringProperty("author").stream;\n'
  //     'parser.getListProperty("features").onElement((property, index) => ...);\n'
  //     'final imageUrl = await parser.getObjectProperty("image.url").future;\n'
  //     'final imageCreatedByStream = parser.getObjectProperty("image.created_by").stream;\n'
  //     'final contentStream = parser.getStringProperty("content").stream;\n';
  String get _json =>
      '{"title": "LLM JSON Stream Parser is Great!","author": "TrulyComs2023@gmail.com","content": "I can now stream and display fields in LLM-streamed JSON data in real-time!","features": ["Property Streaming","Deep Property Access","Fault Tolerant","Lightweight"],"image": {"url": "https://raw.githubusercontent.com/ComsIndeed/json_stream_parser_demo/main/assets/cover.jpg","created_by": "Gemini AI"}}';

  // Track feature widgets with a ValueNotifier to trigger rebuilds
  final ValueNotifier<List<Widget>> _featureWidgets =
      ValueNotifier<List<Widget>>([]);

  @override
  void initState() {
    final jsonStream = streamTextInChunks(
      text: _json,
      chunkSize: widget.chunkSize,
      interval: widget.interval,
    );

    subscription = jsonStream.listen((chunk) {
      setState(() {
        currentAccumulatedJson += chunk;
      });
    });

    super.initState();
    // Start streaming only if the parent requested it
    if (widget.startImmediately) {
      _startStream();
    }
  }

  void _startStream() async {
    // Ensure any existing controller is closed before starting a new stream
    if (_controller != null && !_controller!.isClosed) {
      try {
        await _controller!.close();
      } catch (_) {}
    }

    _controller = StreamController<String>.broadcast();
    _parser = JsonStreamParser(_controller!.stream);
    _streamedJson = '';
    _isActive = true;

    // Clear previous feature widgets
    _featureWidgets.value = [];

    // Trigger a rebuild so child widgets can subscribe to the new parser
    if (mounted) setState(() {});

    // Set up the onElement callback for features
    _parser!.getListProperty("features").onElement((elementStream, index) {
      // Cast to StringPropertyStream to access the stream
      final stringStream = elementStream as StringPropertyStream;

      // Create a unique key for this feature widget
      final featureKey = UniqueKey();

      // Build the chip widget with AccumulatingStreamBuilder
      final featureWidget = RepaintBoundary(
        key: featureKey,
        child: AccumulatingStreamBuilder(
          stream: stringStream.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Chip(
              label: Text(snapshot.data!),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
      );

      // Add to the list and trigger rebuild
      _featureWidgets.value = [..._featureWidgets.value, featureWidget];
    });

    await for (final chunk in streamTextInChunks(
      text: _json,
      chunkSize: widget.chunkSize,
      interval: widget.interval,
    )) {
      if (!mounted || !_isActive) break;
      setState(() {
        _streamedJson += chunk;
      });
      _controller!.add(chunk);
    }

    if (mounted && _controller != null && !_controller!.isClosed) {
      await _controller!.close();
    }
  }

  @override
  void dispose() {
    _isActive = false;
    subscription?.cancel();
    if (_controller != null && !_controller!.isClosed) {
      try {
        _controller!.close();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardContent = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: SizedBox(
          width: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 40,
                child: FittedBox(child: _buildJsonView(isDark)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "Traditional JSON parsing",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      Container(
                        height: 600,
                        width: 400,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _parser != null
                            ? _buildOutput()
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Streaming JSON parsing",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      Container(
                        height: 600,
                        width: 400,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _parser != null
                            ? _buildStreamingOutput()
                            : const SizedBox.shrink(),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: widget.allowExpansion
          ? cardContent
          : SizedBox(
              height: 1000,
              child: SingleChildScrollView(
                child: cardContent,
              ),
            ),
    );
  }

  Widget _buildJsonView(bool isDark) {
    final fullJson = _json;
    final streamedLength = _streamedJson.length;

    return SelectableText.rich(
      TextSpan(
        style: GoogleFonts.robotoMono(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black,
        ),
        children: [
          // Already streamed part (highlighted)
          TextSpan(
            text: _streamedJson,
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          // Remaining part (ghosted)
          if (streamedLength < fullJson.length)
            TextSpan(
              text: fullJson.substring(streamedLength),
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }

  // Custom output builder - CUSTOMIZE THIS PART for your specific demo needs!
  Widget _buildOutput() {
    try {
      final map = jsonDecode(currentAccumulatedJson);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            map["title"],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(
            height: 20,
          ),
          Card(
            child: Column(
              children: [
                Image.network(
                  map["image"]["url"],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Text(
                  "Created by: " + map["image"]["created_by"],
                  style: Theme.of(context).textTheme.titleMedium,
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text.rich(
            TextSpan(
              text: "Author: ",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
              children: [
                TextSpan(
                  text: map["author"],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            map["content"],
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(
            height: 20,
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (final feature in map["features"])
                Chip(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  label: Text(feature),
                ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8));
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            Text("Waiting for full JSON"),
          ],
        ),
      );
    }
  }

  Widget _buildStreamingOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccumulatingStreamBuilder(
          stream: _parser!.getStringProperty("title").stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            return Text(
              snapshot.data!,
              style: Theme.of(context).textTheme.headlineSmall,
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedSize(
            alignment: Alignment.topCenter,
            duration: 200.ms,
            curve: Curves.easeInOutCubic,
            child: FutureBuilder(
                future: _parser!.getStringProperty("image.url").future,
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Image.network(
                          asyncSnapshot.data!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            .animate()
                            .fadeIn(duration: 200.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        AccumulatingStreamBuilder(
                          stream: _parser!
                              .getStringProperty("image.created_by")
                              .stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              "Created by: ${snapshot.data!}",
                              style: Theme.of(context).textTheme.titleMedium,
                            )
                                .animate()
                                .fadeIn(duration: 200.ms)
                                .scale(begin: const Offset(0.8, 0.8));
                          },
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        AccumulatingStreamBuilder(
          stream: _parser!.getStringProperty("author").stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Text.rich(
              TextSpan(
                text: "Author: ",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w300),
                children: [
                  TextSpan(
                    text: snapshot.data!,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
        SizedBox(
          height: 20,
        ),
        AccumulatingStreamBuilder(
          stream: _parser!.getStringProperty("content").stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            return Text(
              snapshot.data!,
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
        SizedBox(
          height: 20,
        ),
        ValueListenableBuilder<List<Widget>>(
          valueListenable: _featureWidgets,
          builder: (context, featureWidgets, child) {
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: featureWidgets,
            );
          },
        )
      ],
    );
  }
}
