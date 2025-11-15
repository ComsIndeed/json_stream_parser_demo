import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_stream_parser_demo/pages/ui_generation_demo/widget_stream_handler.dart';
import 'package:json_stream_parser_demo/pages/ui_generation_demo/streaming_widget_builder.dart';

void main() {
  group('WidgetStreamHandler Tests', () {
    test('exampleJson should be valid JSON', () {
      final handler = WidgetStreamHandler();
      expect(handler.exampleJson, isNotEmpty);
      expect(handler.exampleJson, contains('uiRoot'));
      expect(handler.exampleJson, contains('scaffold'));
    });

    test('Initial state should be correct', () {
      final handler = WidgetStreamHandler();
      expect(handler.rootWidget, isNull);
      expect(handler.accumulatedJson, isEmpty);
      expect(handler.isBuilding, isFalse);
    });

    test('runDemo should update isBuilding state', () async {
      final handler = WidgetStreamHandler();

      // Start the demo
      handler.runDemo(5, 10);

      // Should be building initially
      expect(handler.isBuilding, isTrue);

      // Wait a bit for the stream to complete
      await Future.delayed(const Duration(seconds: 2));

      // Should have accumulated JSON
      expect(handler.accumulatedJson, isNotEmpty);
    });
  });

  group('StreamableWidget Tests', () {
    testWidgets('StreamingText should build correctly',
        (WidgetTester tester) async {
      final widget = StreamingText(text: 'Hello World');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget.build(tester.element(find.byType(Scaffold))),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('StreamingButton should build correctly',
        (WidgetTester tester) async {
      final widget = StreamingButton(
        text: 'Click Me',
        buttonStyle: StreamingButtonStyle.filled,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget.build(tester.element(find.byType(Scaffold))),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });
  });
}
