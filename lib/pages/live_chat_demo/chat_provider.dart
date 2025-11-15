// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const Map<String, List<String>> models = {
  'Google': [
    'gemini-2.5-flash-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ],
  'Groq': [
      
    ]
  };

class ChatProvider with ChangeNotifier {
  List<ChatMessage> messages = [];
  StreamingChatMessage? streamingMessage;
  bool isGenerating = false;

  String get defaultModelInstructions => "";

  String geminiApiKey = "";
  String groqApiKey = "";

  FutureOr<void> sendMessage(
      {String? message,
      required String modelProvider,
      required String modelName,
      String? customModelInstructions}) async {
    if (message == null || message.isEmpty) return;

    final modelInstructions =
        customModelInstructions ?? defaultModelInstructions;
    final relevantApiKey = (modelProvider == 'Google'
        ? geminiApiKey
        : modelProvider == 'Groq'
            ? groqApiKey
            : throw UnsupportedError(
                'Model provider $modelProvider is not supported'));

    final userChatMessage =
        ChatMessage(message: message, role: ChatMessageRole.user);
    messages.add(userChatMessage);
    notifyListeners();

    try {
      final modelResponseStream = _sendMessageAdapter(
          modelProvider: modelProvider,
          modelName: modelName,
          modelInstructions: modelInstructions,
          relevantApiKey: relevantApiKey,
          messages: messages);

      streamingMessage = StreamingChatMessage(stream: modelResponseStream);
      isGenerating = true;
      notifyListeners();

      String accumulatedResponse = "";
      modelResponseStream.listen((chunk) => accumulatedResponse += chunk);
      await modelResponseStream.join("");
      final modelMessage = ChatMessage(
          message: accumulatedResponse, role: ChatMessageRole.model);
      streamingMessage = null;
      messages.add(modelMessage);
      isGenerating = false;
      notifyListeners();
    } catch (e) {
      final errorMessage = ChatMessage(
          message: "An error occured:\n\n$e", role: ChatMessageRole.error);
      messages.add(errorMessage);
      isGenerating = false;
      notifyListeners();
    }
  }
}

Stream<String> _sendMessageAdapter(
    {required String modelProvider,
    required String modelName,
    required String modelInstructions,
    required String relevantApiKey,
    required List<ChatMessage> messages}) {
  if (modelProvider == 'Groq') {
    throw UnimplementedError();
  }
  if (modelProvider == 'Google') {
    // throw UnimplementedError();

    final model = GenerativeModel(
        model: modelName,
        apiKey: relevantApiKey,
        systemInstruction: Content.system(modelInstructions));
    final contents = messages.map((chatMessage) => Content(
        chatMessage.role == ChatMessageRole.error
            ? "model"
            : chatMessage.role.name,
        [TextPart(chatMessage.message)]));
    final stream = model.generateContentStream(contents).asBroadcastStream();
    return stream.map((e) => e.text ?? "");
  }
  throw UnsupportedError(
      'Model provider `$modelProvider` is not yet supported');
}

class ChatMessage {
  final ChatMessageRole role;
  final String message;
  ChatMessage({required this.message, required this.role});
}

class StreamingChatMessage {
  final role = ChatMessageRole.model;
  final Stream<String> stream;

  StreamingChatMessage({required this.stream});
}

enum ChatMessageRole { user, model, error }
