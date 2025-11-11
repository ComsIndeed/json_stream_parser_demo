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
      child: const Text(
        'This is a note widget. It can be used to display important information or reminders to the user.',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
