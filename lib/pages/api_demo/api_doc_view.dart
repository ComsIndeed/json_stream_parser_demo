import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_stream_parser_demo/utils/accumulating_stream_builder.dart';

enum ApiDocOutputType { stream, future }

class ApiDocView extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Stream<String>? stream;
  final Future<String>? future;
  final ApiDocOutputType type;
  final int streamKey;

  const ApiDocView({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.stream,
    this.future,
    required this.type,
    required this.streamKey,
  });

  @override
  Widget build(BuildContext context) {
    // Build the output widget based on the type
    final Widget output;

    if (type == ApiDocOutputType.stream && stream != null) {
      // Handle stream with AccumulatingStreamBuilder
      output = AccumulatingStreamBuilder(
        key: ValueKey('${title}_$streamKey'),
        stream: stream!,
        builder: (context, snapshot) {
          return Card(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.blueAccent, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                snapshot.data ?? "",
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      );
    } else if (type == ApiDocOutputType.future && future != null) {
      // Handle future with FutureBuilder
      output = FutureBuilder<String>(
        key: ValueKey('${title}_$streamKey'),
        future: future,
        builder: (context, snapshot) {
          return Card(
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.blueAccent, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                snapshot.data ?? "",
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      );
    } else {
      output = const Text("");
    }

    return ListTile(
      leading: leading,
      title: Text(title, style: GoogleFonts.robotoMono()),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(subtitle), output],
      ),
    );
  }
}
