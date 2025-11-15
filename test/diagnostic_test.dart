import 'dart:convert';
import 'package:json_stream_parser_demo/pages/ui_generation_demo/widget_stream_handler.dart';

void main() async {
  print('=== Testing WidgetStreamHandler ===\n');

  final handler = WidgetStreamHandler();

  print('1. Testing exampleJson:');
  print('   Length: ${handler.exampleJson.length}');
  print('   Valid JSON: ${_isValidJson(handler.exampleJson)}');
  print('   Contains uiRoot: ${handler.exampleJson.contains('uiRoot')}');
  print('');

  print('2. Testing initial state:');
  print('   rootWidget: ${handler.rootWidget}');
  print('   accumulatedJson: "${handler.accumulatedJson}"');
  print('   isBuilding: ${handler.isBuilding}');
  print('');

  print('3. Running demo with chunk size 50, interval 10ms...');
  handler.runDemo(50, 10);

  print('   Immediately after runDemo:');
  print('   isBuilding: ${handler.isBuilding}');
  print('');

  // Wait for stream to complete
  await Future.delayed(const Duration(seconds: 3));

  print('4. After 3 seconds:');
  print('   accumulatedJson length: ${handler.accumulatedJson.length}');
  print('   rootWidget: ${handler.rootWidget}');
  print('   isBuilding: ${handler.isBuilding}');
  print('');

  if (handler.rootWidget != null) {
    print('✅ SUCCESS: Widget was built!');
  } else {
    print('❌ FAILURE: Widget was NOT built!');
    print('   Accumulated JSON: ${handler.accumulatedJson}');
  }
}

bool _isValidJson(String str) {
  try {
    jsonDecode(str);
    return true;
  } catch (e) {
    return false;
  }
}
