import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    TextSpan(text: snapshot.data ?? ""),
                  ],
                ),
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ).animate().scaleXY(begin: 0.2, curve: Curves.easeOutBack);
        },
      );
    } else if (type == ApiDocOutputType.future && future != null) {
      // Handle future with FutureBuilder
      output = FutureBuilder<String>(
        key: ValueKey('${title}_$streamKey'),
        future: future,
        builder: (context, snapshot) {
          return Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.chevron_right,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    TextSpan(text: snapshot.data ?? ""),
                  ],
                ),
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ).animate().scaleXY(begin: 0.2, curve: Curves.easeOutBack);
        },
      );
    } else {
      output = const Text("");
    }

    return ListTile(
      // leading: leading,
      title: Text(
        title,
        style: GoogleFonts.robotoMono().copyWith(
          backgroundColor: type == ApiDocOutputType.stream
              ? Theme.of(context).colorScheme.primaryContainer.withAlpha(128)
              : Theme.of(context).colorScheme.secondaryContainer.withAlpha(128),
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(subtitle), output],
      ),
    );
  }
}
