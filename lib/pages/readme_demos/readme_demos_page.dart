import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demos/string_stream_demo.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demos/list_trap_demo.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demos/dual_api_demo.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demos/syntax_examples_demo.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demos/edge_cases_demo.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demos/error_handling_demo.dart';
import 'package:json_stream_parser_demo/pages/readme_demos/demos/completion_demo.dart';

class ReadmeDemosPage extends StatefulWidget {
  const ReadmeDemosPage({super.key});

  @override
  State<ReadmeDemosPage> createState() => _ReadmeDemosPageState();
}

class _ReadmeDemosPageState extends State<ReadmeDemosPage> {
  int _streamKey = 0;
  bool _startOnRebuild = false;

  void _runStream() {
    setState(() {
      _startOnRebuild = true;
      _streamKey++;
    });
  }

  void _resetStream() {
    setState(() {
      _startOnRebuild = false;
      _streamKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space &&
              (HardwareKeyboard.instance.logicalKeysPressed
                      .contains(LogicalKeyboardKey.shiftLeft) ||
                  HardwareKeyboard.instance.logicalKeysPressed
                      .contains(LogicalKeyboardKey.shiftRight))) {
            _resetStream();
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            _runStream();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('README Demos'),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'run_all',
              onPressed: _runStream,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run All (Space)'),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: 'reset_all',
              onPressed: _resetStream,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset (Shift+Space)'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            StringStreamDemo(
              key: ValueKey('demo1_$_streamKey'),
              startImmediately: _startOnRebuild,
            ),
            ListTrapDemo(
              key: ValueKey('demo2_$_streamKey'),
              startImmediately: _startOnRebuild,
            ),
            DualApiDemo(
              key: ValueKey('demo3_$_streamKey'),
              startImmediately: _startOnRebuild,
            ),
            SyntaxExamplesDemo(
              key: ValueKey('demo4_$_streamKey'),
              startImmediately: _startOnRebuild,
            ),
            EdgeCasesDemo(
              key: ValueKey('demo5_$_streamKey'),
              startImmediately: _startOnRebuild,
            ),
            ErrorHandlingDemo(
              key: ValueKey('demo6_$_streamKey'),
              startImmediately: _startOnRebuild,
            ),
            CompletionDemo(
              key: ValueKey('demo7_$_streamKey'),
              startImmediately: _startOnRebuild,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
