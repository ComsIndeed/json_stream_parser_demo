import 'package:flutter/material.dart';
import 'package:json_stream_parser_demo/homepage.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  ColorScheme get _colorScheme => ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness:
            _themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
      );

  void _toggleThemeMode() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      darkTheme: ThemeData.dark().copyWith(colorScheme: _colorScheme),
      theme: ThemeData().copyWith(colorScheme: _colorScheme),
      home: Homepage(
        onThemeToggle: _toggleThemeMode,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1920, name: DESKTOP),
          Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}
