import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_stream_parser/classes/json_stream_parser.dart';
import 'package:json_stream_parser/json_stream_parser.dart';
import '../../utils/stream_text_in_chunks.dart' as local_utils;
import 'streaming_widget_builder.dart';

class WidgetStreamHandler with ChangeNotifier {
  Stream<String>? _currentStream;
  JsonStreamParser? _parser;
  int _streamKey = 0;
  StreamableWidget? _rootWidget;
  String _accumulatedJson = '';
  bool _isBuilding = false;

  Stream<String>? get currentStream => _currentStream;
  JsonStreamParser? get parser => _parser;
  int get streamKey => _streamKey;
  StreamableWidget? get rootWidget => _rootWidget;
  String get accumulatedJson => _accumulatedJson;
  bool get isBuilding => _isBuilding;

  // Example JSON for the demo
  String get exampleJson => jsonEncode({
        "uiRoot": {
          "objectType": "widget",
          "widgetName": "scaffold",
          "pageId": "shoppingApp",
          "showAppBar": true,
          "appBarTitle": "Shopping List",
          "child": {
            "objectType": "widget",
            "widgetName": "column",
            "children": [
              {
                "objectType": "widget",
                "widgetName": "card",
                "child": {
                  "objectType": "widget",
                  "widgetName": "column",
                  "children": [
                    {
                      "objectType": "widget",
                      "widgetName": "text",
                      "text": "Welcome to Your Shopping List!",
                    },
                    {
                      "objectType": "widget",
                      "widgetName": "sizedBox",
                      "height": 8.0,
                    },
                    {
                      "objectType": "widget",
                      "widgetName": "text",
                      "text": "Add items to keep track of your shopping.",
                    },
                  ]
                }
              },
              {
                "objectType": "widget",
                "widgetName": "sizedBox",
                "height": 16.0,
              },
              {
                "objectType": "widget",
                "widgetName": "card",
                "child": {
                  "objectType": "widget",
                  "widgetName": "listTile",
                  "title": "Apples",
                  "subtitle": "Fresh Red Apples - \$3.99",
                  "leadingIcon": 57517,
                }
              },
              {
                "objectType": "widget",
                "widgetName": "card",
                "child": {
                  "objectType": "widget",
                  "widgetName": "listTile",
                  "title": "Bread",
                  "subtitle": "Whole Wheat - \$2.49",
                  "leadingIcon": 58732,
                }
              },
              {
                "objectType": "widget",
                "widgetName": "card",
                "child": {
                  "objectType": "widget",
                  "widgetName": "listTile",
                  "title": "Milk",
                  "subtitle": "Organic 2% - \$4.99",
                  "leadingIcon": 59129,
                }
              },
              {
                "objectType": "widget",
                "widgetName": "sizedBox",
                "height": 16.0,
              },
              {
                "objectType": "widget",
                "widgetName": "row",
                "mainAxisAlignment": "spaceEvenly",
                "children": [
                  {
                    "objectType": "widget",
                    "widgetName": "button",
                    "text": "Add Item",
                    "buttonStyle": "filled",
                  },
                  {
                    "objectType": "widget",
                    "widgetName": "button",
                    "text": "Clear All",
                    "buttonStyle": "dangerous",
                  },
                ]
              },
            ]
          }
        }
      });

  void runDemo(int chunkSize, int intervalMs) {
    _isBuilding = true;
    _accumulatedJson = '';
    _rootWidget = null;
    notifyListeners();

    // Create stream controller
    final controller = StreamController<String>.broadcast();

    // Update stream
    _streamKey++;
    _currentStream = controller.stream;
    _parser = JsonStreamParser(controller.stream);

    // Start streaming after a delay
    Future.delayed(const Duration(milliseconds: 50), () async {
      // Stream the JSON text
      local_utils
          .streamTextInChunks(
        text: exampleJson,
        chunkSize: chunkSize,
        interval: Duration(milliseconds: intervalMs),
      )
          .listen(
        (chunk) {
          _accumulatedJson += chunk;
          controller.add(chunk);
          notifyListeners();
        },
        onDone: () {
          controller.close();
        },
        onError: (error) => controller.addError(error),
      );

      // Parse and build widgets
      await _buildWidgetsFromStream();
    });
  }

  Future<void> _buildWidgetsFromStream() async {
    if (_parser == null) return;

    try {
      final uiRootMap = await _parser!.getMapProperty('uiRoot').future;
      _rootWidget = await _buildWidgetFromMap(uiRootMap);
      _isBuilding = false;
      notifyListeners();
    } catch (e) {
      print('Error building widgets: $e');
      _isBuilding = false;
      notifyListeners();
    }
  }

  Future<StreamableWidget?> _buildWidgetFromMap(
      Map<dynamic, dynamic> map) async {
    final widgetName = map['widgetName'] as String?;
    if (widgetName == null) return null;

    switch (widgetName) {
      case 'scaffold':
        final childMap = map['child'] as Map?;
        StreamableWidget? child;
        if (childMap != null) {
          child = await _buildWidgetFromMap(childMap);
        }
        return StreamingScaffold(
          pageId: map['pageId'] as String?,
          showAppBar: map['showAppBar'] as bool? ?? false,
          appBarTitle: map['appBarTitle'] as String?,
          child: child,
        );

      case 'column':
        final childrenList = map['children'] as List?;
        final children = <StreamableWidget>[];
        if (childrenList != null) {
          for (var childMap in childrenList) {
            if (childMap is Map) {
              final widget = await _buildWidgetFromMap(childMap);
              if (widget != null) children.add(widget);
            }
          }
        }
        return StreamingColumn(
          children: children,
          mainAxisAlignment: _parseMainAxisAlignment(map['mainAxisAlignment']),
          crossAxisAlignment:
              _parseCrossAxisAlignment(map['crossAxisAlignment']),
        );

      case 'row':
        final childrenList = map['children'] as List?;
        final children = <StreamableWidget>[];
        if (childrenList != null) {
          for (var childMap in childrenList) {
            if (childMap is Map) {
              final widget = await _buildWidgetFromMap(childMap);
              if (widget != null) children.add(widget);
            }
          }
        }
        return StreamingRow(
          children: children,
          mainAxisAlignment: _parseMainAxisAlignment(map['mainAxisAlignment']),
          crossAxisAlignment:
              _parseCrossAxisAlignment(map['crossAxisAlignment']),
        );

      case 'listView':
        final childrenList = map['children'] as List?;
        final children = <StreamableWidget>[];
        if (childrenList != null) {
          for (var childMap in childrenList) {
            if (childMap is Map) {
              final widget = await _buildWidgetFromMap(childMap);
              if (widget != null) children.add(widget);
            }
          }
        }
        return StreamingListView(children: children);

      case 'text':
        return StreamingText(text: map['text'] as String? ?? '');

      case 'card':
        final childMap = map['child'] as Map?;
        StreamableWidget? child;
        if (childMap != null) {
          child = await _buildWidgetFromMap(childMap);
        }
        return StreamingCard(child: child);

      case 'button':
        return StreamingButton(
          text: map['text'] as String? ?? '',
          buttonStyle: _parseButtonStyle(map['buttonStyle']),
        );

      case 'textField':
        return StreamingTextField(
          hintText: map['hintText'] as String?,
          textFieldStyle: _parseTextFieldStyle(map['textFieldStyle']),
        );

      case 'listTile':
        return StreamingListTile(
          title: map['title'] as String?,
          subtitle: map['subtitle'] as String?,
          leadingIcon: _parseIconData(map['leadingIcon']),
        );

      case 'icon':
        final iconCode = map['icon'] as int?;
        if (iconCode != null) {
          return StreamingIcon(
              icon: IconData(iconCode, fontFamily: 'MaterialIcons'));
        }
        return null;

      case 'divider':
        return StreamingDivider();

      case 'sizedBox':
        return StreamingSizedBox(
          width: (map['width'] as num?)?.toDouble(),
          height: (map['height'] as num?)?.toDouble(),
        );

      case 'container':
        final childMap = map['child'] as Map?;
        StreamableWidget? child;
        if (childMap != null) {
          child = await _buildWidgetFromMap(childMap);
        }
        return StreamingContainer(
          child: child,
          width: (map['width'] as num?)?.toDouble(),
          height: (map['height'] as num?)?.toDouble(),
        );

      default:
        return null;
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(dynamic value) {
    if (value == null) return MainAxisAlignment.start;
    switch (value.toString()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(dynamic value) {
    if (value == null) return CrossAxisAlignment.center;
    switch (value.toString()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  StreamingButtonStyle _parseButtonStyle(dynamic value) {
    if (value == null) return StreamingButtonStyle.elevated;
    switch (value.toString()) {
      case 'filled':
        return StreamingButtonStyle.filled;
      case 'outlined':
        return StreamingButtonStyle.outlined;
      case 'text':
        return StreamingButtonStyle.text;
      case 'dangerous':
        return StreamingButtonStyle.dangerous;
      case 'elevated':
        return StreamingButtonStyle.elevated;
      default:
        return StreamingButtonStyle.elevated;
    }
  }

  StreamingTextFieldStyle _parseTextFieldStyle(dynamic value) {
    if (value == null) return StreamingTextFieldStyle.outlined;
    switch (value.toString()) {
      case 'underlined':
        return StreamingTextFieldStyle.underlined;
      case 'noOutline':
        return StreamingTextFieldStyle.noOutline;
      case 'outlined':
        return StreamingTextFieldStyle.outlined;
      default:
        return StreamingTextFieldStyle.outlined;
    }
  }

  IconData? _parseIconData(dynamic value) {
    if (value is int) {
      return IconData(value, fontFamily: 'MaterialIcons');
    }
    return null;
  }

  void reset() {
    _streamKey++;
    _currentStream = null;
    _parser = null;
    _rootWidget = null;
    _accumulatedJson = '';
    _isBuilding = false;
    notifyListeners();
  }
}
