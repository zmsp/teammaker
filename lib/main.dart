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
      theme: ThemeData.from(colorScheme: ColorScheme.dark()),
      // darkTheme: ThemeData.from(colorScheme: ColorScheme.dark()),

      home: CellRendererScreen(),
    );
  }
}
