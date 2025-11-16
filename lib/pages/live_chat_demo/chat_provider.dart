// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:llm_json_stream/classes/json_stream_parser.dart';

const Map<String, List<String>> models = {
  'Google': [
    'gemini-2.5-flash-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ],
  'Groq': []
};

class ChatProvider with ChangeNotifier {
  List<Widget> messageWidgets = [];
  bool isGenerating = false;
  bool showRawJson = false;
  String? currentRawJson;

  String get defaultModelInstructions => """You are a helpful AI assistant.

CRITICAL: You MUST respond with ONLY valid JSON. Do not use markdown code blocks. Do not add any text before or after the JSON.

Your response must be a JSON object with this exact structure:
{
  "parts": [
    {"objectType": "message", "content": "your response here"}
  ]
}

Rules:
- Start immediately with { and end with }
- No markdown, no explanations, just JSON
- Use "message" for normal responses
- Use "thought" to show your reasoning (optional)
- Use "dartCode" for code examples (optional)
- Escape special characters properly (\\n for newlines, \\" for quotes)

Simple example:
{"parts":[{"objectType":"message","content":"Hello! How can I help you?"}]}""";

  String geminiApiKey = "";
  String groqApiKey = "";

  void toggleRawJsonDisplay() {
    showRawJson = !showRawJson;
    notifyListeners();
  }

  void sendMessage({
    required String message,
    required String modelProvider,
    required String modelName,
    String? geminiApiKey,
    String? groqApiKey,
    String? customModelInstructions,
  }) async {
    if (message.isEmpty) return;
    if (geminiApiKey != null) this.geminiApiKey = geminiApiKey;
    if (groqApiKey != null) this.groqApiKey = groqApiKey;

    final modelInstructions =
        customModelInstructions ?? defaultModelInstructions;
    final relevantApiKey = (modelProvider == 'Google'
        ? geminiApiKey ?? this.geminiApiKey
        : modelProvider == 'Groq'
            ? groqApiKey ?? this.groqApiKey
            : throw UnsupportedError(
                'Model provider $modelProvider is not supported'));

    if (relevantApiKey.isEmpty) {
      messageWidgets
          .add(_buildErrorWidget("No API key provided for $modelProvider"));
      notifyListeners();
      return;
    }

    // Add user message widget
    messageWidgets.add(_buildUserMessageWidget(message));
    notifyListeners();

    try {
      final modelResponseStream = _sendMessageAdapter(
          modelProvider: modelProvider,
          modelName: modelName,
          modelInstructions: modelInstructions,
          relevantApiKey: relevantApiKey,
          messageHistory: [message]);

      // Create a placeholder streaming widget
      final streamingWidgetIndex = messageWidgets.length;
      messageWidgets.add(_buildStreamingPlaceholder());
      isGenerating = true;
      currentRawJson = '';
      notifyListeners();

      // Parse the JSON stream
      await _parseAndBuildResponse(modelResponseStream, streamingWidgetIndex);

      isGenerating = false;
      currentRawJson = null;
      notifyListeners();
    } catch (e) {
      messageWidgets.add(_buildErrorWidget("An error occurred:\n\n$e"));
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> _parseAndBuildResponse(
      Stream<String> stream, int widgetIndex) async {
    final List<StreamSubscription> subscriptions = [];
    String accumulatedRawJson = '';

    try {
      // Stream is already broadcast from _sendMessageAdapter
      // Listen to accumulate raw JSON
      final rawJsonSubscription = stream.listen(
        (chunk) {
          accumulatedRawJson += chunk;
          currentRawJson = accumulatedRawJson;
          notifyListeners();
          print('DEBUG: Received chunk: $chunk'); // Debug
        },
        onError: (error) {
          print('DEBUG: Stream error: $error'); // Debug
        },
        onDone: () {
          print('DEBUG: Stream done. Total: $accumulatedRawJson'); // Debug
        },
      );
      subscriptions.add(rawJsonSubscription);

      final parser = JsonStreamParser(stream);

      // Container to hold all the part data as it streams
      final parts = <PartData>[];

      // Get the parts array from the JSON stream
      parser.getListProperty(
        'parts',
        onElement: (propertyStream, index) async {
          // Ensure we have space in our list
          while (parts.length <= index) {
            parts.add(PartData());
          }

          final partData = parts[index];

          // Get the map property stream to access nested properties
          // We'll wait for the complete map since the API is simpler
          final mapFuture = propertyStream.future;
          mapFuture.then((map) {
            if (map is Map) {
              partData.objectType = map['objectType'] as String?;
              partData.content = map['content'] as String?;

              // Rebuild widgets
              _rebuildResponseWidgets(widgetIndex, parts);
            }
          });
        },
      );

      // Wait for all parts to complete with timeout
      await parser.getListProperty('parts').future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Response parsing timed out after 30 seconds');
        },
      );

      // Final rebuild
      _rebuildResponseWidgets(widgetIndex, parts);

      // Clean up subscriptions
      for (var sub in subscriptions) {
        sub.cancel();
      }
    } on TimeoutException catch (e) {
      print('DEBUG: Timeout - Raw JSON: $accumulatedRawJson'); // Debug
      final errorMsg = "Parsing timeout: ${e.message}\n\n"
          "The model may not have returned valid JSON format. "
          "Enable 'Show Raw JSON' in settings to see the actual response.";
      messageWidgets[widgetIndex] = _buildErrorWidget(errorMsg);

      // Clean up subscriptions on error
      for (var sub in subscriptions) {
        sub.cancel();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      print('DEBUG: Parse error: $e'); // Debug
      print('DEBUG: Stack trace: $stackTrace'); // Debug
      print('DEBUG: Raw JSON: $accumulatedRawJson'); // Debug

      final errorMsg = "Error parsing response: $e\n\n"
          "The model's response couldn't be parsed as JSON. "
          "Enable 'Show Raw JSON' in settings to see the actual response.";
      messageWidgets[widgetIndex] = _buildErrorWidget(errorMsg);

      // Clean up subscriptions on error
      for (var sub in subscriptions) {
        sub.cancel();
      }

      notifyListeners();
    }
  }

  void _rebuildResponseWidgets(int widgetIndex, List<PartData> parts) {
    final partWidgets = <Widget>[];

    for (var part in parts) {
      final objectType = part.objectType;
      final content = part.content;

      if (objectType != null && content != null) {
        Widget partWidget;

        switch (objectType) {
          case 'message':
            partWidget = _buildMessagePartWidget(content);
            break;
          case 'thought':
            partWidget = _buildThoughtPartWidget(content);
            break;
          case 'dartCode':
            partWidget = _buildDartCodePartWidget(content);
            break;
          default:
            partWidget =
                _buildMessagePartWidget("Unknown part type: $objectType");
        }

        partWidgets.add(partWidget);
      }
    }

    // Update the message with all parts
    if (partWidgets.isNotEmpty) {
      messageWidgets[widgetIndex] = _buildModelResponseWidget(partWidgets);
      notifyListeners();
    } else if (parts.isNotEmpty) {
      // Parts exist but not complete yet - show loading
      messageWidgets[widgetIndex] = _buildStreamingPlaceholder();
      notifyListeners();
    }
  }

  Widget _buildUserMessageWidget(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 512),
          child: Card(
            color: null, // Will use theme
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SelectableText(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingPlaceholder() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text("Generating response..."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelResponseWidget(List<Widget> partWidgets) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 512),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: partWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagePartWidget(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MarkdownBody(
        data: content,
        selectable: true,
      ),
    );
  }

  Widget _buildThoughtPartWidget(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: SelectableText(
                content,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDartCodePartWidget(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.code, size: 16),
                const SizedBox(width: 8),
                const Text(
                  "Dart Code",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              content,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 512),
          child: Card(
            color: Colors.red.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      message,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Stream<String> _sendMessageAdapter({
  required String modelProvider,
  required String modelName,
  required String modelInstructions,
  required String relevantApiKey,
  required List<String> messageHistory,
}) {
  if (modelProvider == 'Groq') {
    throw UnimplementedError('Groq provider not yet implemented');
  }
  if (modelProvider == 'Google') {
    final model = GenerativeModel(
      model: modelName,
      apiKey: relevantApiKey,
      systemInstruction: Content.system(modelInstructions),
    );

    // For now, just send the latest message
    // TODO: Implement proper conversation history
    final contents = messageHistory.map((msg) => Content.text(msg));

    final stream = model.generateContentStream(contents).asBroadcastStream();
    return stream.map((e) => e.text ?? "");
  }
  throw UnsupportedError(
      'Model provider `$modelProvider` is not yet supported');
}

/// Helper class to track streaming part data
class PartData {
  String? objectType;
  String? content;

  PartData({this.objectType, this.content});
}
