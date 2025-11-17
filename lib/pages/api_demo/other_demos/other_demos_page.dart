import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:llm_json_stream/classes/json_stream_parser.dart';
import 'package:llm_json_stream/classes/property_stream.dart';
import 'package:json_stream_parser_demo/utils/stream_text_in_chunks.dart';

class OtherDemosPage extends StatefulWidget {
  const OtherDemosPage({super.key});

  @override
  State<OtherDemosPage> createState() => _OtherDemosPageState();
}

class _OtherDemosPageState extends State<OtherDemosPage> {
  bool _isDarkMode = false;
  int _streamKey = 0;
  int _intervalMs = 50;
  int _chunkSize = 3;
  bool _isSliderVisible = true;
  bool _allowExpansion = false;
  bool _startOnRebuild =
      false; // whether newly created demo items should start streaming

  Duration get _interval => Duration(milliseconds: _intervalMs);

  @override
  void initState() {
    super.initState();
    // Don't auto-run - let user control when to start
  }

  void _runStream() {
    setState(() {
      _startOnRebuild = true;
      _streamKey++;
    });
  }

  void _resetStream() {
    // Create new demo items but do NOT start their streams.
    setState(() {
      _startOnRebuild = false;
      _streamKey++;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            // Shift+Space -> reset/clear outputs (do not auto-start)
            if (event.logicalKey == LogicalKeyboardKey.space &&
                (HardwareKeyboard.instance.logicalKeysPressed
                        .contains(LogicalKeyboardKey.shiftLeft) ||
                    HardwareKeyboard.instance.logicalKeysPressed
                        .contains(LogicalKeyboardKey.shiftRight))) {
              _resetStream();
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              // Space -> run stream
              _runStream();
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('JSON Stream Parser - Comprehensive Demos'),
            actions: [
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleTheme,
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                onPressed: _runStream,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Run Stream (Space)'),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.extended(
                onPressed: _resetStream,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Stream (Shift+Space)'),
              ),
            ],
          ),
          body: ResizableContainer(
            direction: Axis.horizontal,
            children: [
              ResizableChild(
                  divider: ResizableDivider(color: Colors.grey[100]),
                  child: Center()),
              ResizableChild(
                divider: ResizableDivider(
                    color: Colors.grey[100], thickness: 1, padding: 32),
                size: ResizableSize.ratio(0.8),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Controls Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSliderVisible = !_isSliderVisible;
                                });
                              },
                              child: Text(
                                "Stream Controls",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (_isSliderVisible) ...[
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: const Text("Allow Items to Expand"),
                                subtitle: const Text(
                                  "When enabled, items can expand without affecting list layout",
                                ),
                                value: _allowExpansion,
                                onChanged: (value) {
                                  setState(() {
                                    _allowExpansion = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Text("Chunk Size:"),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Slider(
                                      value: _chunkSize.toDouble(),
                                      min: 1,
                                      max: 20,
                                      divisions: 19,
                                      label: _chunkSize.toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _chunkSize = value.toInt();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_chunkSize.toString()),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text("Interval (ms):"),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Slider(
                                      value: _intervalMs.toDouble(),
                                      min: 10,
                                      max: 500,
                                      divisions: 49,
                                      label: _intervalMs.toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _intervalMs = value.toInt();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_intervalMs.toString()),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DemoItem(
                      key: ValueKey('demo1_$_streamKey'),
                      title: 'String Property Future',
                      code:
                          'await parser.getStringProperty("user.name").future;',
                      json: '{"user": {"name": "Alice", "age": 30}}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) => _StringFutureDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo2_$_streamKey'),
                      title: 'String Property Stream',
                      code: 'parser.getStringProperty("user.email").stream;',
                      json:
                          '{"user": {"email": "alice@example.com", "verified": true}}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) => _StringStreamDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo3_$_streamKey'),
                      title: 'Atomic Properties (Multiple Properties)',
                      code: 'await parser.getStringProperty("name").future;\n'
                          'await parser.getStringProperty("city").future;\n'
                          'await parser.getStringProperty("country").future;\n'
                          'await parser.getStringProperty("status").future;',
                      json:
                          '{"name": "Bob", "city": "NYC", "country": "USA", "status": "active"}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) =>
                          _AtomicPropertiesDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo4_$_streamKey'),
                      title: 'Nested Property Access',
                      code:
                          'await parser.getStringProperty("company.department.team.lead").future;',
                      json:
                          '{"company": {"department": {"team": {"lead": "Charlie", "members": 5}}}}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) => _NestedPropertyDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo5_$_streamKey'),
                      title: 'List Access via Index',
                      code:
                          'await parser.getStringProperty("users[1].name").future;',
                      json:
                          '{"users": [{"name": "Alice"}, {"name": "Bob"}, {"name": "Charlie"}]}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) => _ListIndexDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo6_$_streamKey'),
                      title: 'Chaining Property Getters',
                      code:
                          'await parser.getProperty("users[0]").getStringProperty("email").future;',
                      json:
                          '{"users": [{"name": "Alice", "email": "alice@example.com"}]}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) => _ChainingDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo7_$_streamKey'),
                      title: 'List onElement - Object Futures',
                      code:
                          'parser.getListProperty("products", onElement: ...);',
                      json:
                          '{"products": [{"id": 1, "name": "Widget"}, {"id": 2, "name": "Gadget"}]}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) =>
                          _ListOnElementObjectsDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo8_$_streamKey'),
                      title: 'List onElement - String Streams',
                      code:
                          'parser.getListProperty("tags", onElement: ...) [Stream<String>];',
                      json:
                          '{"tags": ["flutter", "dart", "json", "streaming"]}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) =>
                          _ListOnElementStringsDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo9_$_streamKey'),
                      title: 'Edge Case - Triple Quoted Multi-line JSON',
                      code:
                          'await parser.getStringProperty("config.message").future;',
                      json: '''
              {
                "config": {
                  "message": "Hello\\nWorld",
                  "multiline": true
                }
              }''',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) =>
                          _EdgeCaseMultilineDemo(parser: parser),
                    ),
                    const SizedBox(height: 32),
                    _DemoItem(
                      key: ValueKey('demo10_$_streamKey'),
                      title: 'Edge Case - Special Characters',
                      code:
                          'await parser.getStringProperty("data.text").future;',
                      json:
                          r'{"data": {"text": "Quote: \"Hello\", Tab:\t, Newline:\n"}}',
                      interval: _interval,
                      chunkSize: _chunkSize,
                      allowExpansion: _allowExpansion,
                      startImmediately: _startOnRebuild,
                      builder: (parser) =>
                          _EdgeCaseSpecialCharsDemo(parser: parser),
                    ),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
              ResizableChild(
                  divider: ResizableDivider(color: Colors.grey[100]),
                  child: Center()),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoItem extends StatefulWidget {
  final String title;
  final String code;
  final String json;
  final Duration interval;
  final int chunkSize;
  final bool allowExpansion;
  final bool startImmediately;
  final Widget Function(JsonStreamParser parser) builder;

  const _DemoItem({
    super.key,
    required this.title,
    required this.code,
    required this.json,
    required this.interval,
    required this.chunkSize,
    required this.allowExpansion,
    required this.builder,
    required this.startImmediately,
  });

  @override
  State<_DemoItem> createState() => _DemoItemState();
}

class _DemoItemState extends State<_DemoItem> {
  StreamController<String>? _controller;
  JsonStreamParser? _parser;
  String _streamedJson = '';
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    // Start streaming only if the parent requested it
    if (widget.startImmediately) {
      _startStream();
    }
  }

  void _startStream() async {
    // Ensure any existing controller is closed before starting a new stream
    if (_controller != null && !_controller!.isClosed) {
      try {
        await _controller!.close();
      } catch (_) {}
    }

    _controller = StreamController<String>.broadcast();
    _parser = JsonStreamParser(_controller!.stream);
    _streamedJson = '';
    _isActive = true;

    // Trigger a rebuild so child widgets can subscribe to the new parser
    if (mounted) setState(() {});

    // Use an async for-loop so we can break early if disposed or cancelled
    await for (final chunk in streamTextInChunks(
      text: widget.json,
      chunkSize: widget.chunkSize,
      interval: widget.interval,
    )) {
      if (!mounted || !_isActive) break;
      setState(() {
        _streamedJson += chunk;
      });
      _controller!.add(chunk);
    }

    if (mounted && _controller != null && !_controller!.isClosed) {
      await _controller!.close();
    }
  }

  @override
  void dispose() {
    _isActive = false;
    if (_controller != null && !_controller!.isClosed) {
      try {
        _controller!.close();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              widget.code,
              style: GoogleFonts.robotoMono(
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildJsonView(isDark),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _parser != null
                ? widget.builder(_parser!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );

    return Card(
      elevation: 2,
      child: widget.allowExpansion
          ? cardContent
          : SizedBox(
              height: 400,
              child: SingleChildScrollView(
                child: cardContent,
              ),
            ),
    );
  }

  Widget _buildJsonView(bool isDark) {
    final fullJson = widget.json;
    final streamedLength = _streamedJson.length;

    return SelectableText.rich(
      TextSpan(
        children: [
          // Already streamed part (highlighted)
          TextSpan(
            text: _streamedJson,
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          // Remaining part (ghosted)
          if (streamedLength < fullJson.length)
            TextSpan(
              text: fullJson.substring(streamedLength),
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                color: isDark ? Colors.grey[700] : Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}

// Demo 1: String Future
class _StringFutureDemo extends StatelessWidget {
  final JsonStreamParser parser;

  const _StringFutureDemo({required this.parser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: parser.getStringProperty('user.name').future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        return Text(
          snapshot.data!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Demo 2: String Stream
class _StringStreamDemo extends StatefulWidget {
  final JsonStreamParser parser;

  const _StringStreamDemo({required this.parser});

  @override
  State<_StringStreamDemo> createState() => _StringStreamDemoState();
}

class _StringStreamDemoState extends State<_StringStreamDemo> {
  String _accumulated = '';

  @override
  void initState() {
    super.initState();
    widget.parser.getStringProperty('user.email').stream.listen((chunk) {
      if (mounted) {
        setState(() {
          _accumulated += chunk;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _accumulated,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

// Demo 3: Atomic Properties
class _AtomicPropertiesDemo extends StatelessWidget {
  final JsonStreamParser parser;

  const _AtomicPropertiesDemo({required this.parser});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _PropertyChip(
          label: 'name',
          future: parser.getStringProperty('name').future,
        ),
        _PropertyChip(
          label: 'city',
          future: parser.getStringProperty('city').future,
        ),
        _PropertyChip(
          label: 'country',
          future: parser.getStringProperty('country').future,
        ),
        _PropertyChip(
          label: 'status',
          future: parser.getStringProperty('status').future,
        ),
      ],
    );
  }
}

class _PropertyChip extends StatelessWidget {
  final String label;
  final Future<String> future;

  const _PropertyChip({required this.label, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Chip(
          label: Text(
            '$label: ${snapshot.data}',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          padding: const EdgeInsets.all(8),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Demo 4: Nested Property
class _NestedPropertyDemo extends StatelessWidget {
  final JsonStreamParser parser;

  const _NestedPropertyDemo({required this.parser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: parser.getStringProperty('company.department.team.lead').future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Text(
          snapshot.data!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Demo 5: List Index Access
class _ListIndexDemo extends StatelessWidget {
  final JsonStreamParser parser;

  const _ListIndexDemo({required this.parser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: parser.getStringProperty('users[1].name').future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Text(
          snapshot.data!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Demo 6: Chaining
class _ChainingDemo extends StatelessWidget {
  final JsonStreamParser parser;

  const _ChainingDemo({required this.parser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future:
          parser.getMapProperty('users[0]').getStringProperty("email").future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Text(
          snapshot.data ?? 'N/A',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Demo 7: List onElement - Objects
class _ListOnElementObjectsDemo extends StatefulWidget {
  final JsonStreamParser parser;

  const _ListOnElementObjectsDemo({required this.parser});

  @override
  State<_ListOnElementObjectsDemo> createState() =>
      _ListOnElementObjectsDemoState();
}

class _ListOnElementObjectsDemoState extends State<_ListOnElementObjectsDemo> {
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    widget.parser.getListProperty(
      'products',
      onElement: (propertyStream, index) async {
        final mapPropertyStream = propertyStream as MapPropertyStream;
        final map = await mapPropertyStream.future;
        if (mounted) {
          setState(() {
            _items.add(map as Map<String, dynamic>);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._items.asMap().entries.map((entry) {
          final product = entry.value;
          final index = entry.key;
          return Chip(
            label: Text(
              '[$index] $product',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            padding: const EdgeInsets.all(8),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .scale(begin: const Offset(0.8, 0.8));
        })
      ],
    );
  }
}

// Demo 8: List onElement - Strings
class _ListOnElementStringsDemo extends StatefulWidget {
  final JsonStreamParser parser;

  const _ListOnElementStringsDemo({required this.parser});

  @override
  State<_ListOnElementStringsDemo> createState() =>
      _ListOnElementStringsDemoState();
}

class _ListOnElementStringsDemoState extends State<_ListOnElementStringsDemo> {
  final List<String> _items = [];
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    widget.parser.getListProperty<String>(
      'tags',
      onElement: (propertyStream, index) async {
        setState(() {
          _items.add('');
        });

        final stringStream = propertyStream as StringPropertyStream;
        final sub = stringStream.stream.listen((chunk) {
          if (mounted) {
            setState(() {
              _items[index] += chunk;
            });
          }
        });
        _subscriptions.add(sub);
      },
    );
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _items.map((tag) {
        if (tag.isEmpty) return const SizedBox.shrink();
        return Chip(
          label: Text(
            tag,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          padding: const EdgeInsets.all(8),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      }).toList(),
    );
  }
}

// Demo 9: Edge Case - Multiline
class _EdgeCaseMultilineDemo extends StatelessWidget {
  final JsonStreamParser parser;

  const _EdgeCaseMultilineDemo({required this.parser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: parser.getStringProperty('config.message').future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Text(
          snapshot.data!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Demo 10: Edge Case - Special Characters
class _EdgeCaseSpecialCharsDemo extends StatelessWidget {
  final JsonStreamParser parser;

  const _EdgeCaseSpecialCharsDemo({required this.parser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: parser.getStringProperty('data.text').future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Text(
          snapshot.data!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}
