import 'package:flutter/material.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({super.key, required this.title, required this.content});

  final Stream<String> title;
  final Stream<String> content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border.all(color: Colors.yellow[700]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<String>(
            stream: title,
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'No Title',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
          ),
          StreamBuilder<String>(
            stream: content,
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'No Content',
                style: Theme.of(context).textTheme.bodyMedium,
              );
            },
          ),
          const SizedBox(height: 8.0),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
