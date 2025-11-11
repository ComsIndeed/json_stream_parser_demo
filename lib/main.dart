import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/homepage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Homepage());
  }
}
