import 'dart:async';
import 'package:flutter/material.dart';
import 'package:json_stream_parser/classes/json_stream_parser.dart';

class StreamNotifier extends ChangeNotifier {
  Stream<String>? _currentStream;
  JsonStreamParser? _parser;
  int _streamKey = 0;

  Stream<String>? get currentStream => _currentStream;
  JsonStreamParser? get parser => _parser;
  int get streamKey => _streamKey;

  void updateStream(Stream<String> stream) {
    _streamKey++;
    _currentStream = stream;
    _parser = JsonStreamParser(stream);
    notifyListeners();
  }

  void reset() {
    _streamKey++;
    _currentStream = null;
    _parser = null;
    notifyListeners();
  }
}
