import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/pages/api_demo/api_demo_page.dart';
import 'package:json_stream_parser_demo/pages/live_chat_demo/live_chat_demo_page.dart';

class Homepage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const Homepage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: PageView(
                controller: _pageController,
                children: [
                  ApiDemoPage(),
                  LiveChatDemoPage(),
                  UiGenerationDemoPage(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton.icon(
                      label: const Text('Previous'),
                      onPressed: () => _pageController.previousPage(
                        duration: Durations.medium1,
                        curve: Curves.bounceInOut,
                      ),
                      icon: Icon(Icons.arrow_left),
                    ),
                    IconButton(
                      key: ValueKey<bool>(widget.isDarkMode),
                      onPressed: widget.onThemeToggle,
                      icon: Icon(
                        widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      ),
                    ),
                    Spacer(),
                    FilledButton.icon(
                      label: const Text('Next'),
                      onPressed: () => _pageController.nextPage(
                        duration: Durations.medium1,
                        curve: Curves.bounceInOut,
                      ),
                      icon: Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UiGenerationDemoPage extends StatelessWidget {
  const UiGenerationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Page 3'));
  }
}
