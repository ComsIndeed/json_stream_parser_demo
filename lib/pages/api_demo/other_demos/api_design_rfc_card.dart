import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_stream_parser_demo/utils/stream_text_in_chunks.dart';

class ApiDesignComparisonCard extends StatefulWidget {
  final bool startImmediately;
  final Duration interval;
  final int chunkSize;

  const ApiDesignComparisonCard({
    super.key,
    required this.startImmediately,
    this.interval = const Duration(milliseconds: 50),
    this.chunkSize = 1,
  });

  @override
  State<ApiDesignComparisonCard> createState() =>
      _ApiDesignComparisonCardState();
}

class _ApiDesignComparisonCardState extends State<ApiDesignComparisonCard> {
  String _streamedJson = '';
  String _streamedEmail = '';
  bool _isActive = false;

  // The full JSON data we are simulating
  final String _fullJson = '''
{
  "users": [
    {"name": "Alice", "email": "alice@example.com"},
    {"name": "Bob", "email": "bob@example.com"}
  ]
}''';

  // The target email we want to "extract"
  final String _targetEmail = "alice@example.com";

  @override
  void initState() {
    super.initState();
    if (widget.startImmediately) {
      _startStream();
    }
  }

  void _startStream() async {
    _streamedJson = '';
    _streamedEmail = '';
    _isActive = true;
    if (mounted) setState(() {});

    // We simulate the stream by chunking the _fullJson
    await for (final chunk in streamTextInChunks(
      text: _fullJson,
      chunkSize: widget.chunkSize,
      interval: widget.interval,
    )) {
      if (!mounted || !_isActive) break;

      setState(() {
        _streamedJson += chunk;
        // Simple logic to simulate "extracting" the email as it appears in the JSON
        // We look for the email value in the streamed JSON.
        // This is a visual simulation, so we can just check if the streamed JSON
        // contains parts of the email.
        // A more robust way for this specific demo:
        // The email starts at index 43 (approx) in the minified JSON, but we have formatted JSON.
        // Let's just see how much of the email is present in the _streamedJson.

        // Find where "alice@example.com" starts in _fullJson
        final emailStart = _fullJson.indexOf(_targetEmail);
        if (emailStart != -1 && _streamedJson.length > emailStart) {
          int lengthInStream = _streamedJson.length - emailStart;
          if (lengthInStream > _targetEmail.length) {
            lengthInStream = _targetEmail.length;
          }
          _streamedEmail = _targetEmail.substring(0, lengthInStream);
        }
      });
    }
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? draculaTheme : githubTheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "API Design Comparison",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Comparison of different API patterns for accessing streaming properties.",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Side: Options
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildOption(
                        context,
                        "1. Current API:",
                        'parser.getStringProperty("users[0].email").stream.listen((chunk) { ... });',
                        theme,
                      ),
                      _buildOption(
                        context,
                        "2. Simpler API:",
                        'jsonStream["users[0].email"].stream.listen((chunk) { ... });',
                        theme,
                      ),
                      _buildOption(
                        context,
                        "3. Typed API:",
                        'jsonStream["users[0].email"].asString.stream.listen((chunk) { ... });',
                        theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Side: Visualization
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Incoming JSON Stream",
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withAlpha(50)),
                        ),
                        child: _buildGhostJsonView(isDark),
                      ),
                      const SizedBox(height: 24),
                      Text("Actual Result (users[0].email)",
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withAlpha(100)),
                        ),
                        child: Text(
                          _streamedEmail.isEmpty
                              ? "Waiting..."
                              : _streamedEmail,
                          style: GoogleFonts.robotoMono(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue[200] : Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label, String code,
      Map<String, TextStyle> theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: HighlightView(
                code,
                language: 'dart',
                theme: theme,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: GoogleFonts.robotoMono(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGhostJsonView(bool isDark) {
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
            ),
          ),
          // Remaining part (ghosted)
          if (streamedLength < _fullJson.length)
            TextSpan(
              text: _fullJson.substring(streamedLength),
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                color: isDark ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }
}
