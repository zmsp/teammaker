import 'package:flutter/material.dart';
import 'package:teammaker/cell_renderer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Maker',
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark,
      // theme: ThemeData.from(colorScheme: ColorScheme.dark()),
      // darkTheme: ThemeData.from(colorScheme: ColorScheme.dark()),

      home: CellRendererScreen(),
    );
  }
}
