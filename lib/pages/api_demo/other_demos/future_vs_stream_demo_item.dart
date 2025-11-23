import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:json_stream_parser_demo/utils/accumulating_stream_builder.dart';
import 'package:llm_json_stream/classes/json_stream_parser.dart';
import 'package:json_stream_parser_demo/utils/stream_text_in_chunks.dart';

/// Dual-card comparison demo showing .future vs .stream approach
class FutureVsStreamDemoItem extends StatefulWidget {
  final Duration interval;
  final int chunkSize;
  final bool allowExpansion;
  final bool startImmediately;

  const FutureVsStreamDemoItem({
    super.key,
    required this.interval,
    required this.chunkSize,
    required this.allowExpansion,
    required this.startImmediately,
  });

  @override
  State<FutureVsStreamDemoItem> createState() => _FutureVsStreamDemoItemState();
}

class _FutureVsStreamDemoItemState extends State<FutureVsStreamDemoItem> {
  StreamController<String>? _controller;
  JsonStreamParser? _parser;
  String _streamedJson = '';
  bool _isActive = false;

  // Hardcoded values for this demo
  String get _title => 'Future vs Stream Comparison';
  String get _futureCode =>
      'final email = await parser.getStringProperty("email").future;';
  String get _streamCode => 'parser.getStringProperty("email").stream';
  String get _json =>
      '{"name": "John Doe", "email": "john.doe@example.com", "age": 30}';

  @override
  void initState() {
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

    // Trigger a rebuild so child widgets can subscribe to the new parser
    if (mounted) setState(() {});

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
              const SizedBox(height: 20),
              // JSON stream visualization
              SizedBox(
                height: 40,
                child: FittedBox(child: _buildJsonView(isDark)),
              ),
              const SizedBox(height: 40),
              // Two cards side by side
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Future card
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Using .future",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        // Code display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HighlightView(
                            _futureCode,
                            language: 'dart',
                            theme: isDark
                                ? {
                                    ...draculaTheme,
                                    "root": TextStyle(
                                        backgroundColor: Colors.grey[900],
                                        color: const Color(0xfff8f8f2))
                                  }
                                : githubTheme,
                            textStyle: GoogleFonts.robotoMono(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Output display
                        Container(
                          height: 400,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _parser != null
                              ? _buildFutureOutput()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Stream card
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Using .stream",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        // Code display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HighlightView(
                            _streamCode,
                            language: 'dart',
                            theme: isDark
                                ? {
                                    ...draculaTheme,
                                    "root": TextStyle(
                                        backgroundColor: Colors.grey[900],
                                        color: const Color(0xfff8f8f2))
                                  }
                                : githubTheme,
                            textStyle: GoogleFonts.robotoMono(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Output display
                        Container(
                          height: 400,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _parser != null
                              ? _buildStreamOutput()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
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
              height: 800,
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

  // Future approach - waits for complete property before displaying
  Widget _buildFutureOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Waits for complete property",
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<String>(
          future: _parser!.getStringProperty("name").future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("Waiting for name..."),
                ],
              );
            }
            return Text.rich(
              TextSpan(
                text: "Name: ",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                children: [
                  TextSpan(
                    text: snapshot.data!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
        const SizedBox(height: 20),
        FutureBuilder<String>(
          future: _parser!.getStringProperty("email").future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("Waiting for email..."),
                ],
              );
            }
            return Text.rich(
              TextSpan(
                text: "Email: ",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                children: [
                  TextSpan(
                    text: snapshot.data!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
        const SizedBox(height: 20),
        FutureBuilder<num>(
          future: _parser!.getNumberProperty("age").future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("Waiting for age..."),
                ],
              );
            }
            return Text.rich(
              TextSpan(
                text: "Age: ",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                children: [
                  TextSpan(
                    text: snapshot.data!.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
      ],
    );
  }

  // Stream approach - displays property as it streams in
  Widget _buildStreamOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Streams property as it arrives",
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        AccumulatingStreamBuilder(
          stream: _parser!.getStringProperty("name").stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Text.rich(
              TextSpan(
                text: "Name: ",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                children: [
                  TextSpan(
                    text: snapshot.data!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
        const SizedBox(height: 20),
        AccumulatingStreamBuilder(
          stream: _parser!.getStringProperty("email").stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Text.rich(
              TextSpan(
                text: "Email: ",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                children: [
                  TextSpan(
                    text: snapshot.data!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
        const SizedBox(height: 20),
        AccumulatingStreamBuilder(
          stream:
              _parser!.getNumberProperty("age").stream.map((e) => e.toString()),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Text.rich(
              TextSpan(
                text: "Age: ",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                children: [
                  TextSpan(
                    text: snapshot.data!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8));
          },
        ),
      ],
    );
  }
}
