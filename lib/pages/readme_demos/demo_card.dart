import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:llm_json_stream/classes/json_stream_parser.dart';
import 'package:json_stream_parser_demo/utils/stream_text_in_chunks.dart';

class DemoCard extends StatefulWidget {
  final String title;
  final String code;
  final String json;
  final Widget Function(BuildContext context, JsonStreamParser parser) builder;
  final bool startImmediately;
  final int chunkSize;
  final Duration interval;

  const DemoCard({
    super.key,
    required this.title,
    required this.code,
    required this.json,
    required this.builder,
    this.startImmediately = false,
    this.chunkSize = 2,
    this.interval = const Duration(milliseconds: 50),
  });

  @override
  State<DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<DemoCard> {
  StreamController<String>? _controller;
  JsonStreamParser? _parser;
  String _streamedJson = '';
  bool _isActive = false;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    if (widget.startImmediately) {
      _startStream();
    }
  }

  void _startStream() async {
    if (_isStreaming) return;

    // Ensure any existing controller is closed
    await _cleanup();

    setState(() {
      _controller = StreamController<String>.broadcast();
      _parser = JsonStreamParser(_controller!.stream);
      _streamedJson = '';
      _isActive = true;
      _isStreaming = true;
    });

    // Use an async for-loop to stream chunks
    await for (final chunk in streamTextInChunks(
      text: widget.json,
      chunkSize: widget.chunkSize,
      interval: widget.interval,
    )) {
      if (!mounted || !_isActive) break;
      setState(() {
        _streamedJson += chunk;
      });
      _controller!.add(chunk);
    }

    if (mounted) {
      setState(() {
        _isStreaming = false;
      });
    }

    // Don't close controller immediately if we want to allow inspection of final state
    // But for this demo, closing it is fine as the parser handles it.
    // Actually, keeping it open is better for "onComplete" demos if they wait for done.
    // Let's close it to signal done.
    if (_controller != null && !_controller!.isClosed) {
      await _controller!.close();
    }
  }

  Future<void> _cleanup() async {
    _isActive = false;
    if (_controller != null && !_controller!.isClosed) {
      try {
        await _controller!.close();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 32),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _isStreaming ? null : _startStream,
                  icon: _isStreaming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.play_arrow),
                  tooltip: 'Run Demo',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Code Block
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SelectionArea(
                child: HighlightView(
                  widget.code,
                  language: 'dart',
                  theme: isDark ? draculaTheme : githubTheme,
                  padding: const EdgeInsets.all(16),
                  textStyle: GoogleFonts.robotoMono(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // JSON View
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Incoming Stream:',
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  _buildJsonView(isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Result View
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Result:',
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 16),
                  _parser != null
                      ? widget.builder(context, _parser!)
                      : const Center(
                          child: Text('Press Play to Start',
                              style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonView(bool isDark) {
    final fullJson = widget.json;
    final streamedLength = _streamedJson.length;

    return SelectableText.rich(
      TextSpan(
        children: [
          // Already streamed part (highlighted)
          TextSpan(
            text: _streamedJson,
            style: GoogleFonts.robotoMono(
              fontSize: 14,
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
                fontSize: 14,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}
