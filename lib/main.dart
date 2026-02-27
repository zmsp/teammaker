import 'package:flutter/material.dart';
import 'package:teammaker/cell_renderer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Maker Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Professional Indigo
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.dark,
          surface: Colors.black,
          surfaceContainer:
              const Color(0xFF121212), // Slightly lighter for cards
        ),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.dark,
      home: CellRendererScreen(),
    );
  }
}
